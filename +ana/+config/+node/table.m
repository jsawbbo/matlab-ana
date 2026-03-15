classdef table < ana.config.node.base & matlab.mixin.indexing.RedefinesParen
    %ana.config.node.table      FIXME
    %
    %   Detailed explanation goes here
    
    %% class data

    %% scheme
    methods(Hidden)
        function build(obj,sch)
            arguments
                obj ana.config.node.table
                sch = []
            end

            if isempty(sch)
                sch = obj.Scheme;
                if isempty(sch)
                    return
                end
            end

            FIXME
        end

        function res = validate(obj,sch)
            arguments
                obj ana.config.node.table
                sch = []
            end

            if isempty(sch)
                if isempty(obj.Scheme)
                    res = true;
                    return
                end
                sch = obj.Scheme;
            end

            res = false;
            FIXME
        end
    end
    
    %% public
    methods
        function obj = table(options)
            %table    Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            poptions = ana.util.passoptions(options, {'Parent','Scheme'});
            obj@ana.config.node.list(poptions{:});
        end
    end
end