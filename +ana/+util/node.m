classdef node < matlab.mixin.indexing.RedefinesParen & handle
    %ANA.UTIL.NODE  A data node with attributes and children.
    %
    %   FIXME
    %

    properties (Access=public)
        Name        = ''        % Node name.
        Attributes  = {}        % Attributes.
        Data        = []        % Data content.
    end

    properties (Access=protected)
        Children    = []        % Node children, if this is a tree node.
    end

    properties (Access=protected)
        Handler  % TODO use Handler if present...
    end
        
    methods
        function set.Attributes(obj,value)
            % FIXME check 'value'
            obj.Attributes = value;
        end
    end    
    
    methods (Access=protected)
        function varargout = parenReference(obj, indexOp)
            assert(iscell(obj.Children), 'not a tree node')
            tmpCell = obj.Children.(indexOp(1));
            node = tmpCell{1};
            if isscalar(indexOp)
                varargout{1} = node;
                return;
            end
            % This code forwards all indexing operations after
            % the first parentheses reference to MATLAB for handling.
            [varargout{1:nargout}] = node.(indexOp(2:end));
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
                    obj.Children.(indexOp(1)) = varargin(1);
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
            if iscell(obj.Children)
                [varargout{1:nargout}] = size(obj.Children,varargin{:});
            else
                [varargout{1:nargout}] = size(obj.Data,varargin{:});
            end
        end

        function indented_disp(obj,level)
            arguments
                obj ana.util.node
                level (1,1) double {mustBeInteger, mustBeNonnegative} = 1
            end

            indent = sprintf('%*s', 2*level, '');

            if isempty(obj.Name)
                fprintf('%s<> <a href="matlab:help ana.util.node">ana.util.node</a>:\n', indent);
            else
                fprintf('%s%s <a href="matlab:help ana.util.node">ana.util.node</a>:\n', indent, obj.Name);
            end

            fprintf('%sAttributes: ',indent);
            if ~isempty(obj.Attributes)
                if isstruct(obj.Attributes)
                end
            end
            fprintf('\n');

            if iscell(obj.Children)
                fprintf('%sNode: %d children\n', indent, length(obj.Children));
                for c = 1:length(obj.Children)
                    indented_disp(obj.Children{c},level+1)
                end
            else
                if isempty(obj.Data)
                    fprintf('%sData: <empty>\n', indent);
                else
                    fprintf('%sData:\n', indent);
                    indented_disp(obj.Data,level+1)
                end
            end

            fprintf('\n');
        end

        function disp(obj)
            obj.indented_disp(1);
        end
    end

    methods (Access=public)
        function obj = node(options)
            %NODE           Construct an instance of this class.
            %
            %   FIXME
            arguments
                options.Name = ''       % Node name.
                options.Attributes = {} % Node attributes.
                options.Children = []   % Children (use {} for empty node).
                options.Data = []       % Node data.
            end
            obj.Name = options.Name;
            obj.Attributes = options.Attributes;
            obj.Children = options.Children;
            obj.Data = options.Data;
        end

        function res = isempty(obj)
            %ISEMPTY        Check if node is empty.
            res = isempty(obj.Children) & isempty(obj.Data);
        end

        function res = isnode(obj)
            %ISNODE         Check if this is a tree node.
            res = iscell(obj.Children);
        end

        function res = get(obj)
            %GET            Get node data.
            assert(~obj.isnode(), "cannot get data from a tree node")
            res = obj.Data;
        end

        function set(obj,data)
            %SET            Set node data.
            assert(~obj.isnode(), "cannot assign data to a tree node")
            obj.Data = data;
        end
    end
end