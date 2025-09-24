classdef map < ana.config.node & matlab.mixin.indexing.RedefinesDot
    %MAP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Hidden,Access=protected)
        Properties = struct();          % Internal properties node.
    end
    
    methods(Hidden)
        function res = properties(obj)
            res = fieldnames(obj.Properties);
        end        

        function res = fieldnames(obj)
            res = fieldnames(obj.Properties);
        end

        function disp(obj,level)
            arguments
                obj ana.config.node.map
                level {mustBeScalarOrEmpty} = 1
            end

            fn = fieldnames(obj.Properties);
            for i = 1:numel(fn)
                key = fn{i};
                fprintf("\n%s%s", pad('',level*4),key)
                disp(obj.Properties.(key), level+1);
            end

            if level == 1
                fprintf("\n")
            end
        end
    end

    methods (Access=protected)
        function n = dotListLength(obj,indexOp,indexContext)
            n = listLength(obj.Properties,indexOp,indexContext);
        end

        function varargout = dotReference(obj,indexOp)
            tmp = obj.Properties.(indexOp(1));
            if numel(indexOp) > 1
                for i = 2:numel(indexOp)
                    tmp = tmp.(indexOp(i));
                end
            end
            [varargout{1:nargout}] = tmp;
        end

        function obj = dotAssign(obj,indexOp,varargin)
            FIXME 
        end
    end

    methods
        function obj = map(options)
            %MAP Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            poptions = ana.util.passoptions(options, {'Parent','Scheme'});
            obj@ana.config.node(poptions{:});
        end

        function res = ismodified(obj)
            %ISMODIFIED Check if modified.
            %
            arguments
                obj ana.config.node.map
            end
           
            res = false;
            f = fieldnames(obj);
            for k = 1:numel(f)
                if obj.Properties.(f{k}).ismodified()
                    res = true;
                    break;
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
        
        function set(obj, v)
            arguments
                obj ana.config.node.map
                v struct
            end

            % fill map
            havescheme = ~isempty(obj.Scheme);
            subscheme = [];
            fn = fieldnames(v);
            for i = 1:numel(fn)
                key = fn{i};
                value = v.(key);

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
                        obj.Properties.(key) = map;
                    end
                elseif iscell(value)
                    if havescheme
                        FIXME()
                    else
                        seq = ana.config.node.seq(Parent=obj,Scheme=subscheme);
                        seq.set(value);
                        obj.Properties.(key) = seq;
                    end
                else
                    obj.Properties.(key) = ana.config.node.value(value,Parent=obj,Scheme=subscheme);
                end
            end

            % fill missing keys from scheme
            if havescheme
                FIXME()
            end
        end

        function res = get(obj)
            arguments
                obj ana.config.node.map
            end

            res = struct();
            fn = fieldnames(obj.Properties);
            for i = 1:numel(fn)
                key = fn{i};
                value = obj.Properties.(key).get();
                res.(key) = value;
            end
        end
    end
end

