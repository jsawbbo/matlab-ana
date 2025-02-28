classdef path
    %ANA.FILESYSTEM.PATH Filesystem path.
    %
    %   Detailed explanation goes here
    %

    properties (GetAccess = protected)
        Parts
    end
    
    methods
        function obj = path(pathname)
            %PATH Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                pathname (1,1) string = ''
            end

            % FIXME
        end
    end
end

