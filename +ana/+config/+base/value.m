classdef value < ana.config.base.node
    %VALUE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Hidden,Access=protected)
        Value = []
        LastValue = []
    end
    
    methods
        function obj = value(options)
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            poptions = ana.util.passoptions(options, {'Parent','Scheme'});
            obj@ana.config.base.node(poptions{:});
        end

        function res = ismodified(obj)
            arguments
                obj ana.config.base.node;
            end

            res = (obj.Value ~= obj.LastValue);
        end

        function reset(obj)
            arguments
                obj ana.config.base.value
            end
            obj.Value = obj.LastValue;
        end

        function apply(obj)
            arguments
                obj ana.config.base.value
            end
            obj.LastValue = obj.Value;
        end

        function res = get(obj)
            arguments
                obj ana.config.base.value
            end
            res = obj.Value;
        end
    end
end

