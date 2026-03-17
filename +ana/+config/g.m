classdef g < handle
    %ana.config.g     Global, unified configuration
    %
    %   This class provides acccess to the global configuration hierarchy. Internally it also
    %   provides mechanisms to avoid concurrent units (such as configuration files).
    %
    %   FIXME

    %% PROPERTIES
    properties (SetAccess = private)
        Tree % FIXME
    end

    properties (SetAccess = private)
        Instance = dictionary(string([]), {});          % Storage for singletons.
    end

    %% INTERFACE
    methods
        function obj = g()
            %G  Construct a singleton instance of this class
            arguments
            end

            persistent singleton
            if ~isempty(singleton)
                obj = singleton;
                return
            end
            singleton = obj;

            
        end
    end
end