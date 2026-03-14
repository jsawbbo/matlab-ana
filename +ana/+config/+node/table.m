classdef table < ana.config.node.base & matlab.mixin.indexing.RedefinesParen
    %ana.config.node.table      FIXME
    %
    %   Detailed explanation goes here
    
    %% class data

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