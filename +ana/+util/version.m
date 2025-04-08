classdef version
    %ANA.TOOL.VERSION Version information
    %
    %   Detailed explanation goes here
    %

    properties (SetAccess = protected)
        Major = 0
        Minor = 0
        Patch = []
        Tweak = []
    end
    
    methods
        function obj = version(str)
            %VERSION Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                str (1,1) string = ''
            end

            if strlength(str) > 0
                % FIXME
            end
        end
    end
end

