classdef scheme 
    %ana.config.scheme        Scheme handler.
    %
    % Schemes define a hierarchical configuration tree. The structure
    % general structure is
    %
    %     key: "key-name"
    %     type: <type-of-entry>
    %     meta:
    %         <meta information...>
    %     content:
    %         <content definition>
    %
    % For further information, see <a href="https://github.com/jsawbbo/matlab-ana/blob/main/scheme/README.md">scheme/README.md</a>.

    %TODO:
    %- fill missing documentation
    %- implement scheme hierarchy (see field 'schemes' in static_data)
    %- make indentation configurable?
    %- add support for units
        
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

            if isempty(static_data)
                static_data = struct(...
                        paths = dictionary(string([]),false), ...
                        schemes = dictionary(string([]),{})...
                    );

                static_data.paths(+(ana.os.paths('toolboxdir')/"scheme")) = true;

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
            %

            % FIXME
        end

        function scan()
            %SCAN       Scan or re-scan scheme hierarchy.

            % FIXME
        end

        function res = load(key)
            %LOAD       Load a scheme (with navigation key).
            %

            res = [];
        end
    end

    %% SCHEME
    methods
        function sch = get(obj,key)
            %GET        Get child content by key.
            %
            
            sch = [];

            if obj.isempty() || ~isfield(obj.Scheme, 'content')
                return
            end

            if ~iscell(obj.Scheme.content)
                return
            end

            for k = 1:numel(obj.Scheme.content)
                child = obj.Scheme.content{k};

                if isequal(child.key, key)
                    sch = ana.config.scheme(child);
                    return;
                end
            end
        end
    end

    methods(Static)
        function id = typeid(value)
            %TYPEID   Infer type of Matlab value.
            if islogical(value)
                id = "logical";
            elseif isnumeric(value)
                if isempty(value)
                    id = "*";
                elseif isinteger(value)
                    id = "integral";
                else
                    id = "numeric";
                end
            elseif ischar(value) || isstring(value)
                id = "string";
            elseif isa(value,"ana.fs.path")
                id = "path";
            elseif isa(value,"ana.type.url")
                id = "url";
            elseif isa(value,"datetime") || isa(value,"ana.type.datetime")
                id = "datetime";
            else
                id = [];
            end
        end
    end

    %% PUBLIC
    methods
        function obj = scheme(doc)
            %SCHEME     Construct a singleton instance of this class
            %
            arguments
                doc (1,:) = []
            end

            if isempty(doc)
                return
            elseif isa(doc, "ana.config.scheme")
                obj = doc;
                return
            end

            % load scheme based on string id
            if ischar(doc) || isstring(doc)
                schemefile = ana.config.scheme.find(doc);
                if isempty(schemefile)
                    error("ANA:config:noSuchScheme", "could not find scheme file")
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
                error("ANA:config:invalidArguments", "neither name of scheme nor scheme struct")
            end

            obj.Scheme = doc;

            % ensure, content is a cell
            if isfield(doc,'content') && ~iscell(doc.content)
                N = numel(doc.content);
                content = cell(N,1);
                for k = 1:N
                    content{k} = doc.content(k);
                end
                obj.Scheme.content = content;
            end
        end

        function res = isempty(obj)
            %ISEMPTY    Check if scheme is empty.
            %
            res = isempty(obj.Scheme);
        end

        function res = version(obj)
            %VERSION    Get scheme version.
            %
            if isempty(obj.Scheme)
                res = [];
            else
                res = obj.Scheme.version;
            end
        end

        function res = kind(obj)
            %KIND   Get "kind of scheme".
            %
            if isempty(obj.Scheme)
                res = [];
                return
            end

            if isfield(obj.Scheme, 'config')
                res = 'config';
            elseif ~isfield(obj.Scheme, 'type')
                res = 'branch';
            else
                res = 'type';
            end
        end

        function id = type(obj)
            %TYPE   Get current node type.
            %
            if isempty(obj.Scheme)
                id = '*';
            else
                id = obj.Scheme.type;
            end
        end

        function res = key(obj)
            %KEY    Get key of current node.
            %
            assert(~isempty(obj.Scheme));
            res = obj.Scheme.key;
        end

        function res = meta(obj)
            %META    Get meta table of current node.
            %
            if isfield(obj.Scheme, 'meta')
                res = obj.Scheme.meta;
            else
                res = [];
            end
        end

        function res = content(obj)
            %CONTENT    Get content (ie. children).
            %
            assert(~isempty(obj.Scheme));

            if ~isfield(obj.Scheme, 'content')
                res = ana.config.scheme();
                return
            end

            res = obj.Scheme.content;
            if iscell(res)
                for k = 1:numel(res)
                    res{k} = ana.config.scheme(res{k});
                end
            else
                res = ana.config.scheme(res);
            end
        end

        function follow = comment(obj,fd,options)
            %COMMENT    Emit comment.
            %
            arguments
                obj (1,1) ana.config.scheme
                fd (1,1) double 
                options.Column (1,1)        % Target column for comments
                options.Level (1,1) = 0     % Nested comment level
            end

            follow = true;
            if isfield(obj.Scheme, 'meta')
                meta = obj.Scheme.meta;
                if isfield(meta,'comment')
                    column_s = pad("", options.Column);
                    indent_s = pad("", options.Level*4);
                    comment = strrep(meta.comment, sprintf('\r'), '');
                    lines = strsplit(comment, '\n', CollapseDelimiters=false);
                    if strlength(lines(end)) == 0
                        lines = lines(1:end-1);
                    end

                    switch (obj.Scheme.type)
                        case "category"
                            cats = obj.Scheme.meta.rules;
                            lines = ["Categories: " + strjoin([cats.value], ", "); ""; lines(:)];
                    end

                    for k = 1:numel(lines)
                        fprintf(fd, "%s# %s%s\n", column_s, indent_s, lines{k});
                    end

                    switch (obj.Scheme.type)
                        case "table"
                            fprintf(fd, "%s# \n", column_s);
                            fprintf(fd, "%s# %sEntries:\n", column_s, indent_s);

                            for k = 1:numel(obj.Scheme.content)
                                node = ana.config.scheme(obj.Scheme.content{k});
                                fprintf(fd, "%s# %s- ""%s""\n", column_s, indent_s, node.Scheme.key);
                                node.comment(fd,Column=options.Column,Level=options.Level+1);
                            end

                            follow = false;
                    end
                end
            end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
