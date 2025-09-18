classdef value < ana.config.base.node
    %VALUE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Hidden,Access=protected)
        Value = []
        LastValue = []
    end
    
    methods
        function obj = value(options)
            %VALUE Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            poptions = namedargs2cell(options);
            obj@ana.config.base.node(poptions{:});
        end

        function res = get(obj)
            arguments
                obj ana.config.base.value
            end
            res = obj.Value;
        end

        function reset(obj)
            obj.Value = obj.LastValue;
        end

        function res = ismodified(obj)
            %ISMODIFIED Check if modified.
            %
            arguments
                obj ana.config.base.node;
            end

            res = (obj.Value ~= obj.LastValue);
        end        
    end
end

