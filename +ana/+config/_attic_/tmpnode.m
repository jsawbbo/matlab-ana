classdef node < handle & matlab.mixin.indexing.RedefinesDot
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

    methods(Static,Hidden)
        function dispField(key,value,width)
            if ischar(value)
                fprintf('%*s: ''%s''\n', width, key, string(value));
            elseif isstring(value)
                fprintf('%*s: "%s"\n', width, key, string(value));
            else
                fprintf('%*s: %s\n', width, key, string(value));
            end
        end
    end

    methods(Hidden)
        function names = properties(obj)
            names = fieldnames(obj.Properties);
        end        

        function names = fieldnames(obj)
            names = fieldnames(obj.Properties);
        end


        function disp(obj,minwidth)
            arguments
                obj ana.config.node
                minwidth = 0
            end

            names = fieldnames(obj.Properties);
            namelen = max(strlength(names));
            if minwidth == 0
                minwidth = namelen+4;
            elseif minwidth < namelen
                minwidth = namelen;
            end

            for i = 1:numel(names)
                key = names{i};
                value = obj.Properties.(key);

                if isa(value,'ana.config.node')
                    fprintf('%*s:\n', minwidth, key);
                    disp(value,minwidth+4);
                elseif isscalar(value) || ischar(value)
                    obj.dispField(key,value,minwidth);
                else
                    error("FIXME")
                end
            end
        end

        % function delete(obj)
        %     %DELETE Destructor.
        % end
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

