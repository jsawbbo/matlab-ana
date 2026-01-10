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
            % obj.Children = obj.Children.(indexOp(1));
            % if isscalar(indexOp)
            %     varargout{1} = obj;
            %     return;
            % end
            % % This code forwards all indexing operations after
            % % the first parentheses reference to MATLAB for handling.
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
            %     obj.Children.(indexOp) = rhs.Children;
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
            % obj.Children.(indexOp) = [];
        end
    end

    methods
        function obj = node()
            %NODE       Construct an instance of this class.
            %
            %   FIXME
        end

        function res = isnode(obj)
            %ISNODE         Check if this is a tree node.
            res = iscell(obj.Children);
        end
    end
end