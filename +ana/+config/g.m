classdef g < handle
    %ana.config.g     Global, unified configuration
    %
    %   This class provides acccess to the global configuration hierarchy. Internally it also
    %   provides mechanisms to avoid concurrent units (such as configuration files).
    %
    %   Note: This is intended for use inside ana.config.file etc. only, do not use directly.

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

        function res = has(obj,name)
            %HAS    Check if object is stored.
            res = obj.Instance.isKey(name);
        end

        function s = get(obj, name)
            %GET    Get object instance by name.
            s = obj.Instance(name);
            s = s{:};
        end

        function set(obj, name, s)
            %SET    Get object instance by name.
            obj.Instance(name) = {s};
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
