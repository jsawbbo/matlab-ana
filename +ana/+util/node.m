classdef node < matlab.mixin.indexing.RedefinesParen & handle
    %ANA.UTIL.NODE  A generic tree node with attributes.
    %
    %   This class represents either, a branch node or a value, accompanied 
    %   by attributes. FIXME
    %

    properties (Access=public)
        Name        = ''            % Node name.
        Attributes  = dictionary    % Attributes.
    end

    properties (Access=protected)
        Value       = []            % (see Data below)
        Children    = []            % Node children (if branch node).
    end

    properties (Dependent)
        Data                        % Data content (if value node).
    end

    methods
        function set.Data(obj,value)
            assert(~iscell(obj.Children), 'cannot assign a value to a branch node')
            obj.Value = value;
        end

        function res = get.Data(obj)
            res = obj.Value;
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

            fprintf('%sAttributes:\n',indent);
            if ~isempty(obj.Attributes)
                if isstruct(obj.Attributes)
                    FIXME
                else
                    try 
                        fields = keys(obj.Attributes);
                        for i = 1:length(fields)
                            k = fields(i);
                            fprintf('%s  %s = %s\n', indent, k, obj.Attributes(k));
                        end
                    catch
                    end
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
                    % indented_disp(obj.Data,level+1)
                    disp(obj.Data)
                end
            end

            fprintf('\n');
        end

        function disp(obj)
            indented_disp(obj,1);
        end
    end

    methods (Access=public)
        function obj = node(options)
            %NODE           Construct an instance of this class.
            %
            %   FIXME
            arguments
                options.Name = ''       % Node name.
                options.Attributes = [] % Node attributes.
                options.Children = []   % Children (use {} for empty node).
                options.Data = []       % Node data.
            end
            obj.Name = options.Name;
            if isa(options.Attributes,'dictionary')
                obj.Attributes = options.Attributes;
            elseif iscell(options.Attributes)
                obj.Attributes = dictionary(options.Attributes{:});
            elseif ~isempty(options.Attributes)
                error('option ''Attributes'' must be a dictionary')
            end
            obj.Children = options.Children;
            if ~iscell(obj.Children)
                obj.Data = options.Data;
            end
        end

        function res = isempty(obj)
            %ISEMPTY        Check if node is empty.
            res = isempty(obj.Children) & isempty(obj.Data);
        end

        function res = isnode(obj)
            %ISNODE         Check if this is a tree node.
            res = iscell(obj.Children);
        end
    end
end