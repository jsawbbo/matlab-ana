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
                        schemes = struct(name = {}, data={})... % FIXME currently unused
                    );

                if isfile(cfgfile)
                    cfg = ana.file.yaml.load(cfgfile);
                    for k = 1:numel(cfg.paths)
                        static_data.paths(cfg.paths{k}) = true;
                    end
                    static_data.schemes = cfg.schemes;
                else
                    static_data.paths(+(ana.os.paths('toolboxdir')/"scheme")) = true;
                end

                data = static_data;
            end

            if ~isempty(data)
                static_data = data;

                cfg.paths = keys(data.paths);
                cfg.schemes = data.schemes;
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
        function build(obj, node)
            arguments
                obj
                node {mustBeAConfigNode(node)}
            end
    
            assert(~isempty(obj.Scheme));

            % check type
            % (FIXME this is not necessary, we are building it....)
            switch (obj.Scheme.type)
                case "map"
                    assert(isa(node,"ana.config.node.map"));
                case "sequence"
                    assert(isa(node,"ana.config.node.seq"));
                case "table"
                    assert(isa(node,"ana.config.node.table"));
                otherwise
                    assert(isa(node,"ana.config.node.value"));
            end

            % handle children
            children = obj.Scheme.children;
            nchildren = numel(children);

            for k = 1:nchildren
                child = children(k);

                switch (child.type)
                    case "map"
                        node.set(child.key, ...
                            ana.config.node.map(Parent=node, Scheme=child));
                    % case "sequence"
                    % case "table"
                    otherwise
                        FIXME()
                end
            end
        end

        function res = validate(obj,node,varargin)
            arguments
                obj
                node {mustBeAConfigNode(node)}
            end

            arguments(Repeating)
                varargin
            end
            
            % FIXME 
            res = false;
        end
    end

    %% INTERFACE
    methods
        function obj = scheme(doc)
            %SCHEME     Construct a singleton instance of this class
            arguments
                doc (1,:)
            end

            if ischar(doc) || isstring(doc)
                schemefile = ana.config.scheme.find(doc);
                if isempty(schemefile)
                    error("ANA:CONFIG:SCHEME_NOT_FOUND", "could not find scheme file")
                end

                doc = ana.file.yaml.load(schemefile);
            end

            if ~isstruct(doc)
                error('ANA:CONFIG:SCHEME:ARGUMENTS', 'neither name of scheme nor scheme struct')
            end

            % FIXME do some checks...

            obj.Scheme = doc;
        end        
    end
end

function res = mustBeAConfigNode(obj)
    % FIXME
    res = true;
end

% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
