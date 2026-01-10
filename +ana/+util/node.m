classdef node < matlab.mixin.indexing.RedefinesParen & handle
    %ANA.UTIL.NODE  A data node with attributes and children.
    %
    %   FIXME
    %

    properties (Access=protected)
        Name        = ''        % Node name.
        Attributes  = {}        % Attributes.
        Children    = []        % Node children, if this is a tree node.
        Data        = []        % Node data.
    end

    methods (Access=protected)
        function varargout = parenReference(obj, indexOp)
            obj.Children = obj.Children.(indexOp(1));
            if isscalar(indexOp)
                varargout{1} = obj;
                return;
            end
            % This code forwards all indexing operations after
            % the first parentheses reference to MATLAB for handling.
            [varargout{1:nargout}] = obj.(indexOp(2:end));
        end

        function obj = parenAssign(obj,indexOp,varargin)
            if isscalar(indexOp)
                assert(nargin==3);
                if iscell(varargin{1})
                    if isempty(varargin{1})
                        assert(~obj.isnode(), '')
                        obj.Children = {};
                    else
                        FIXME
                    end
                else
                    assert(isa(varargin{1},'ana.util.node'), 'expected ana.util.node for child assignment')
                    obj.Children.(indexOp(1)) = varargin{1};
                end
                return;
            end
            [obj.(indexOp(2:end))] = varargin{:};
        end

        function n = parenListLength(obj,indexOp,ctx)
            if numel(indexOp) <= 2
                n = 1;
                return;
            end
            containedObj = obj.(indexOp(1:2));
            n = listLength(containedObj,indexOp(3:end),ctx);
        end

        function obj = parenDelete(obj,indexOp)
            obj.Children.(indexOp) = [];
        end
    end

    methods (Access=public)
        function out = cat(dim,varargin)
            numCatArrays = nargin-1;
            newArgs = cell(numCatArrays,1);
            for ix = 1:numCatArrays
                if isa(varargin{ix},'ArrayWithLabel')
                    newArgs{ix} = varargin{ix}.Children;
                else
                    newArgs{ix} = varargin{ix};
                end
            end
            out = ArrayWithLabel(cat(dim,newArgs{:}));
        end

        function varargout = size(obj,varargin)
            [varargout{1:nargout}] = size(obj.Children,varargin{:});
        end
    end    

    methods (Access=public)
        function obj = node(options)
            %NODE       Construct an instance of this class.
            %
            %   FIXME
            arguments
                options.Name = ''       % Node name.
                options.Children = []   % Children (use {} for empty node).
            end
            obj.Name = options.Name;
            obj.Children = options.Children;
        end

        function res = isnode(obj)
            %ISNODE         Check if this is a tree node.
            res = iscell(obj.Children);
        end
    end
end