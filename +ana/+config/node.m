classdef node < handle
    %ana.config.node    Configuration node base class.
    %
    %   A "configuration node" can be a simple branch node or represent a setting.
    %   These nodes may be accompanied by schemes. 
    %
    
    properties(Hidden,Access=protected)
        Parent = [];                    % Parent node.
        Scheme = [];                    % Scheme node (if available).
    end
    
    methods
        function obj = node(options)
            %node   Construct an instance of this class
            %
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            obj.Parent = options.Parent;
            obj.Scheme = options.Scheme;
        end

        function res = root(obj)
            %root   Find root node.
            %
            arguments
                obj ana.config.base.node;
            end

            res = obj;
            while ~isempty(res.Parent)
                res = res.Parent;
            end
        end

        function res = ismodified(obj) %#ok<*MANU>
            %ismodified     Check if modified.
            %
            arguments
                obj ana.config.base.node;
            end
            
            res = false;
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

        function res = get(obj)
            %get    Get content (YAML conforming).
            arguments
                obj ana.config.node.value
            end
            res = [];
        end

        function set(obj,v)
            %set    Set content (YAML conforming).
        end
    end
end