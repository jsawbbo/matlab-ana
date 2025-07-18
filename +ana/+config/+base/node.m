classdef node < handle
    %ANA.CONFIG.BASE.NODE Configuration node base class.
    %
    %   FIXME
    %
    
    properties(Hidden,Access=protected)
        Parent = [];                    % Parent node.
        Scheme = [];                    % Scheme node (if available).
        Modified = false;               % Modified flag.
    end
    
    methods
        function obj = node(options)
            %NODE Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            obj.Parent = options.Parent;
            obj.Scheme = options.Scheme;
        end

        function res = root(obj)
            %ROOT   Find root node.
            arguments
                obj ana.config.base.node;
            end

            res = obj;
            while ~isempty(res.Parent)
                res = res.Parent;
            end
        end
    end
end