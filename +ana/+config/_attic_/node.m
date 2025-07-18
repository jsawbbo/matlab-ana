classdef node < handle & matlab.mixin.indexing.RedefinesDot & matlab.mixin.indexing.RedefinesParen
    %NODE Configuration node.
    %
    %   Configuration nodes keep track of modifications.
    %
    
    properties(Hidden,Access=protected)
        Properties = struct();          % Internal properties node.
        Parent = [];                    % Parent node.
        Modified = false;               % Modified flag.
        Scheme = [];                    % ?
    end
    
    methods (Access=protected)
        function varargout = dotReference(obj,indexOp)
            [varargout{1:nargout}] = obj.Properties.(indexOp);
        end

        function obj = dotAssign(obj,indexOp,varargin)
            [obj.Properties.(indexOp)] = varargin{:};
        end
        
        function n = dotListLength(obj,indexOp,indexContext)
            n = listLength(obj.Properties,indexOp,indexContext);
        end
    end

    methods (Access=protected)
        function varargout = parenReference(obj, indexOp)
            % obj.ContainedArray = obj.ContainedArray.(indexOp(1));
            % if isscalar(indexOp)
            %     varargout{1} = obj;
            %     return;
            % end
            % [varargout{1:nargout}] = obj.(indexOp(2:end));
        end

        function obj = parenAssign(obj,indexOp,varargin)
            % % Ensure object instance is the first argument of call.
            % if isempty(obj)
            %     obj = varargin{1};
            % end
            % if isscalar(indexOp)
            %     assert(nargin==3);
            %     rhs = varargin{1};
            %     obj.ContainedArray.(indexOp) = rhs.ContainedArray;
            %     return;
            % end
            % [obj.(indexOp(2:end))] = varargin{:};
        end

        function n = parenListLength(obj,indexOp,ctx)
            % if numel(indexOp) <= 2
            %     n = 1;
            %     return;
            % end
            % containedObj = obj.(indexOp(1:2));
            % n = listLength(containedObj,indexOp(3:end),ctx);
        end

        function obj = parenDelete(obj,indexOp)
            % obj.ContainedArray.(indexOp) = [];
        end
    end    

    methods
        function out = cat(dim,varargin)
            numCatArrays = nargin-1;
            newArgs = cell(numCatArrays,1);
            for ix = 1:numCatArrays
                if isa(varargin{ix},'ArrayWithLabel')
                    newArgs{ix} = varargin{ix}.ContainedArray;
                else
                    newArgs{ix} = varargin{ix};
                end
            end
            out = ArrayWithLabel(cat(dim,newArgs{:}));
        end

        function varargout = size(obj,varargin)
            [varargout{1:nargout}] = size(obj.ContainedArray,varargin{:});
        end
    end

    methods
        function obj = node(options)
            %NODE Construct an instance of this class
            arguments
                options.Scheme = [];
            end
        end
    end

end