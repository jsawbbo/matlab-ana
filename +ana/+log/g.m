classdef g 
    %ana.log.g     Logger settings.
    %
    %   Helper to store logger data (such as the log level).

    properties (Constant)
        Logger = ana.util.shared(...
            struct(level=ana.log.level.INFO,...
                file=[]))
    end

    methods (Static)
        function res = level(lvl)
            %level  Get or set log level.
            logger = ana.log.g.Logger;
            if nargin == 0
                res = logger.level;
            else
                res = ana.log.level(lvl);
                logger.level = res;
            end
        end
    end
end