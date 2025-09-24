classdef seq < ana.config.node & matlab.mixin.indexing.RedefinesParen
    %SEQ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Hidden,Access=protected)
        Properties = {};          % Internal properties node.
    end

    % methods (Static, Hidden)
    %     function obj = empty()
    %         obj = ana.config.node.seq();
    %     end
    % end

    methods (Hidden)
        function result = cat(dim,varargin)
            FIXME()
        end

        function result = size(obj,varargin)
            result = numel(obj.Properties);
        end

        function disp(obj,level)
            arguments
                obj ana.config.node.seq
                level {mustBeScalarOrEmpty} = 1
            end

            for key = 1:numel(obj.Properties)
                fprintf("\n%s-", pad('',(level-1)*4))
                disp(obj.Properties{key}, level+1);
            end

            if level == 1
                fprintf("\n")
            end
        end        
    end

    methods (Access=protected)
        function varargout = parenReference(obj, indexOp)
            tmp = obj.Properties.(indexOp(1:end));
            [varargout{1:nargout}] = tmp{1};
        end

        function obj = parenAssign(obj,indexOp,varargin)
            % Ensure object instance is the first argument of call.
            FIXME()
            % if isempty(obj)
            %     obj = varargin{1};
            % end
            % if isscalar(indexOp)
            %     assert(nargin==3);
            %     rhs = varargin{1};
            %     obj.ContainedArray.(indexOp) = rhs.ContainedArray;
            %     return;
            % end
            % [obj.Properties.(indexOp(2:end))] = varargin{:};
        end

        function n = parenListLength(obj,indexOp,ctx)
            containedObj = obj.Properties.(indexOp(1));
            n = listLength(containedObj{:},indexOp(2),ctx);
        end

        function obj = parenDelete(obj,indexOp)
            FIXME
        end
    end    

    methods
        function obj = seq(options)
            %seq    Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            poptions = ana.util.passoptions(options, {'Parent','Scheme'});
            obj@ana.config.node(poptions{:});
        end

        function res = ismodified(obj)
            arguments
                obj ana.config.node.map
            end
           
            res = false;

            for key = 1:numel(obj.Properties)
                if obj.Properties{key}.ismodified()
                    res = true;
                    return
                end
            end
        end

        function apply(obj)
            %apply      Apply changes.
            arguments
                obj ana.config.base.node;
            end
        end

        function reset(obj)
            %reset      Reset changes.
            arguments
                obj ana.config.base.node;
            end
        end
        
        function set(obj, s)
            arguments
                obj ana.config.node.seq
                s cell
            end

            havescheme = ~isempty(obj.Scheme);
            subscheme = [];
            for key = 1:numel(s)
                value = s{key};

                if havescheme
                    % FIXME
                    subscheme = [];
                end

                if isstruct(value)
                    if havescheme
                        FIXME()
                    else
                        map = ana.config.node.map(Parent=obj,Scheme=subscheme);
                        map.set(value);
                        obj.Properties{key} = map;
                    end
                elseif iscell(value)
                    if havescheme
                        FIXME()
                    else
                        seq = ana.config.node.seq(Parent=obj,Scheme=subscheme);
                        seq.set(value);
                        obj.Properties{key} = seq;
                    end
                else
                    obj.Properties{key} = ana.config.node.value(value,Parent=obj,Scheme=subscheme);
                end               
            end
        end

        function res = get(obj)
            arguments
                obj ana.config.node.seq
            end

            N = numel(obj.Properties);
            res = cell(1,N);
            for key = 1:N
                value = obj.Properties{key}.get();
                res{key} = value;
            end
        end
    end
end

