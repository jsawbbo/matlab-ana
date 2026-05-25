classdef scheme 
    %ana.config.scheme        Scheme handler.
    %
    %   FIXME
    %

    %% PROPERTIES
    properties (SetAccess = private)
        Scheme = []
    end

    %% REGISTRY
    methods(Static,Hidden)
        function data = static(data)
            arguments
                data = []
            end

            persistent static_data 

            cfgfile = ana.os.paths('configdir') / "schemes.yml";
            if isempty(static_data)
                static_data = struct(...
                        paths = dictionary(string([]),false), ...
                        schemes = dictionary(string([]),{})... % FIXME currently unused
                    );

                if isfile(cfgfile)
                    cfg = ana.file.yaml.load(cfgfile);
                    for k = 1:numel(cfg.paths)
                        static_data.paths(cfg.paths{k}) = true;
                    end
                else
                    static_data.paths(+(ana.os.paths('toolboxdir')/"scheme")) = true;
                end

                data = static_data;
            end

            if ~isempty(data)
                static_data = data;

                cfg.paths = keys(data.paths);
                ana.file.yaml.save(cfgfile,cfg);
            end

            data = static_data;
        end
    end

    methods(Static)
        function register(path)
            %REGISTER   Registers a path as "scheme" path.

            path = ana.fs.path(path);

            internal = ana.config.scheme.static();
            if internal.paths.isKey(+path)
                return
            end
            internal.paths(+path) = true;
            ana.config.scheme.static(internal);
        end

        function path = find(name)
            %FIND   Find scheme file.
            name = ana.fs.path(name);
            name(end) = name(end) + ".yml";
            if ~name.isrelative()
                name = name(2:end);
            end

            internal = ana.config.scheme.static();
            searchpath = keys(internal.paths);
            for k = 1:numel(searchpath)
                path = ana.fs.path(searchpath{k}) / name;
                if isfile(path)
                    return
                end
            end

            path = [];
        end
    end

    %% SCHEME
    methods
        function sch = get(obj,key)
            %GET    Get scheme by key.
            if isempty(obj.Scheme)
                sch = ana.config.scheme();
                return
            end

            usecell = iscell(obj.Scheme.content);
            for k = 1:numel(obj.Scheme.content)
                if usecell
                    child = obj.Scheme.content{k};
                else
                    child = obj.Scheme.content(k);
                end

                if isequal(child.key, key)
                    sch = child;
                    return;
                end
            end

            sch = [];
        end
    end

    %% INTERFACE
    methods
        function obj = scheme(doc)
            %SCHEME     Construct a singleton instance of this class
            arguments
                doc (1,:) = []
            end

            if isempty(doc)
                return
            end

            if ischar(doc) || isstring(doc)
                schemefile = ana.config.scheme.find(doc);
                if isempty(schemefile)
                    error("ANA:CONFIG:SCHEME_NOT_FOUND", "could not find scheme file")
                end

                internal = obj.static();
                if internal.schemes.isKey(+schemefile)
                    doc = internal.schemes(+schemefile);
                    doc = doc{1};
                else
                    doc = ana.file.yaml.load(schemefile);
                    internal.schemes(+schemefile) = {doc};
                    obj.static(internal);
                end
            end

            if ~isstruct(doc)
                error('ANA:CONFIG:SCHEME:ARGUMENTS', 'neither name of scheme nor scheme struct')
            end

            obj.Scheme = doc;
        end        
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
