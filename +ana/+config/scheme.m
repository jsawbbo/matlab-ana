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
    %- scheme could be a handle class - shouldn't it?
    %- make indentation configurable (start with making it a constant here)?
    %- add support for units
        
    %% PROPERTIES
    properties (SetAccess = private)
        Scheme = []
    end

    %% REGISTRY
    methods(Static,Hidden)
        function res = newcatalog()
            %newcatalog     Helper to create a new catalog entry in the private data.
            res = struct(...
                    index = {}, ...
                    path = {}, ...
                    kind = {}, ...
                    meta = {} ...
                );
        end

        function res = newtree(what)
            %newtree        Helper to create a new tree branch/leaf in the config hierarchy.
            arguments
                what = {}
            end
            res = struct(key=what, ...
                meta=what, ...
                config=what, ...
                branches=what);
        end

        function data = private()
            %private        Persistent internal data.
            %

            persistent store
    
            if isempty(store)
                % main structure
                store = ana.util.shared(struct( ...
                    catalog = ana.config.scheme.newcatalog(), ...
                    tree = ana.config.scheme.newtree(), ...
                    index = ana.type.dict ...
                ));

                % load catalog
                cfgdir = ana.os.paths("configdir");

                schemecat = cfgdir / "internal" / "schemes.yml";
                if schemecat.isfile()
                    try
                        store.catalog = ana.file.yaml.load(string(schemecat));

                        % generate index
                        for k = 1:numel(store.catalog)
                            item = store.catalog(k);
                            store.index(item.index) = ana.fs.path(item.path);
                        end
                    catch me
                        store.catalog = ana.config.scheme.newcatalog();
                        warning("ANA:config:invalidSchemeCatalog", ...
                            "Could not load scheme catalog: %s", string(schemecat));
                    end
                end

                % load config tree
                configtree = cfgdir / "internal" / "configuration.yml";
                if configtree.isfile()
                    try
                        store.tree = ana.file.yaml.load(configtree);
                    catch 
                        store.tree = ana.config.scheme.newtree();
                        warning("ANA:config:invalidConfigurationTree", ...
                            "Could not load configuration tree: %s", string(configtree));
                    end
                end
            end
    
            data = store;
        end
    end

    methods(Static)
        function scan()
            %SCAN       Scan or re-scan scheme hierarchy.
            %

            % prepare
            priv = ana.config.scheme.private();
            priv.catalog = ana.config.scheme.newcatalog();
            priv.tree = ana.config.scheme.newtree();
            priv.index = ana.type.dict;
            
            % toolbox directories
            cfgdir = ana.os.paths("configdir");

            toolboxdirs = {ana.os.paths("toolboxdir")};

            toolboxcfg = cfgdir / "toolbox.yml";
            if toolboxcfg.isfile()
                % FIXME
            end

            % find schemes, load and parse
            for k = 1:numel(toolboxdirs)
                toolbox = toolboxdirs{k};
                files = ana.fs.find(toolbox / "scheme",".*[.]yml");

                for n = 1:numel(files)
                    schemefile = files{n};

                    % load
                    try
                        sch = ana.file.yaml.load(string(schemefile));

                        % kind
                        if isfield(sch, 'config')
                            kind = 'config';
                        elseif ~isfield(sch, 'type')
                            kind = 'branch';
                        else
                            kind = 'type';
                        end

                        % index
                        switch (kind)
                            case "type"
                                index = "/" + string(schemefile(numel(toolbox)+2:end));
                                index = string(index{1}(1:end-4));

                                if isfield(sch,'index')
                                    warning("ANA:Scheme:InvalidIndex", "Scheme file '%s' is neither a branch nor a configuration, ignoring 'index' entry.",...
                                        string(schemefile))
                                    sch = rmfield(sch,'index');
                                end

                            otherwise
                                if ~isfield(sch,'index')
                                    index = "/" + string(schemefile(numel(toolbox)+2:end));
                                    sch.index = string(index{1}(1:end-4));
                                end
                                index = sch.index;
                        end

                        % meta
                        if ~isfield(sch, 'meta')
                            sch.meta = struct();
                        end

                        if ~isfield(sch.meta,'label')
                            p = ana.fs.path(index);
                            p = string(p(end));

                            sch.meta.label = ana.string.title(p);
                        end

                        % catalog
                        priv.catalog(end+1) = struct(...
                            index = index, ...
                            path = string(schemefile), ...
                            kind = kind, ...
                            meta = sch.meta);

                        % index
                        priv.index(index) = sch;

                    catch me
                        %TODO: 
                        %    This should be recorded in the internal configuration. 
                        disp(me)
                    end
                end
            end

            % list branches
            branches = [string([])];
            for k = 1:numel(priv.catalog)
                sch = priv.catalog(k);

                switch (sch.kind)
                    case 'type'
                        % nothing to be done
                    otherwise
                        branches(end+1) = sch.index; %#ok<AGROW>
                end
            end
            branches = sort(branches);

            % assemble hierarchical configuration tree
            stack = {priv.tree};
            for k = 1:numel(branches)
                name = branches(k);
                sch = priv.index(name);

                % current branch key
                branch = ana.fs.path(name);
                key = string(branch(end));

                % copy/cleanup meta
                meta = sch.meta;

                fn = fieldnames(meta);
                for n = 1:numel(fn)
                    switch (fn{n})
                        case {'rules', 'default'}
                            meta = rmfield(meta, fn{n});
                    end
                end

                % copy config
                if isfield(sch, 'config')
                    config = sch.config;
                else
                    config = [];
                end

                % manage stack
                depth = numel(branch)-1;
                %TODO 
                % - if depth > numel(stack), there's possibly an error in a scheme file
                % - better checking required if schemes are missing
                while numel(stack) > depth
                    if isempty(stack{end})
                        stack{end-1}(end).branches = [];   
                    else
                        stack{end-1}(end).branches = stack{end};
                    end
                    stack = stack(1:end-1);
                end

                current = stack{end};

                % add leaf/branch
                node = ana.config.scheme.newtree([]);
                node.key = key;
                node.meta = meta;
                node.config = config;
                node.branches = ana.config.scheme.newtree();

                current(end+1) = node; %#ok<AGROW>
                stack{end} = current;

                % manage stack
                stack = [stack; {node.branches}]; %#ok<AGROW>
            end
            while numel(stack) > 1
                if isempty(stack{end})
                    stack{end-1}(end).branches = [];   
                else
                    stack{end-1}(end).branches = stack{end};
                end
                stack = stack(1:end-1);
            end
            priv.tree = stack{1};

            % save 
            internaldir = cfgdir / "internal";
            if ~internaldir.isfolder()
                mkdir(string(internaldir));
            end

            ana.file.yaml.save(cfgdir / "internal/configuration.yml", priv.tree);
            ana.file.yaml.save(cfgdir / "internal/schemes.yml", priv.catalog);
        end

        function res = load(index)
            %LOAD       Load scheme file index.
            %

            priv = ana.config.scheme.private();
            if ~isfield(priv.index, index)
                error("ANA:Scheme:InvalidIndex", "Scheme index '%s' is not known - maybe rerun ana.config.scheme.scan().", index)
            end

            res = priv.index(index);
            if isa(res,'ana.fs.path')
                res = ana.file.yaml.load(res);
                priv.index(index) = res;
            end
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

            % load from file
            if ~isstruct(doc)
                doc = ana.scheme.config.load(doc);
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
