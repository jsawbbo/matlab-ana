classdef node < handle
    %ANA.CONFIG.BASE.NODE Configuration node base class.
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
            %NODE Construct an instance of this class
            %
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            obj.Parent = options.Parent;
            obj.Scheme = options.Scheme;
        end

        function res = root(obj)
            %ROOT   Find root node.
            %
            arguments
                obj ana.config.base.node;
            end

            res = obj;
            while ~isempty(res.Parent)
                res = res.Parent;
            end
        end

        function res = ismodified(obj)
            %ISMODIFIED Check if modified.
            %
            arguments
                obj ana.config.base.node;
            end
            
            res = false;
        end

        function apply(obj)
            arguments
                obj ana.config.base.node;
            end
        end

        function reset(obj)
            arguments
                obj ana.config.base.node;
            end
        end

        function save(obj)
            arguments
                obj ana.config.base.node;
            end
        end
    end
end