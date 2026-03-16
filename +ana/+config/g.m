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
            %G Construct an instance of this class
        end
    end
end