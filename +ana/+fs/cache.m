classdef cache < handle
    %ANA.FS.CACHE       File and meta-data cache.
    %   
    %
    %
    %
    %

    %% PROPERTIES
    properties (Access = private)
        Instance = false
        Sql = []
    end

    properties(Constant)
        Version = 1
    end

    %% DATABASE 
    methods(Access = protected)
        function dbCreate(obj,sql)
            %DBCREATE   Create database (current version).
            %

            % create version table
            sql.execute(sprintf(...
                "CREATE TABLE db_version (" + ...
                "    version INTEGER PRIMARY KEY" + ...
                ");",obj.Version));

            sql.execute(...
                "INSERT INTO db_version (version) VALUES (?);", ...
                obj.Version);

            % Create file cache table
            sql.execute(...
                "CREATE TABLE file_cache (" + ...
                "    id TEXT PRIMARY KEY," + ...
                "    size BIGINT," + ...
                "    file TEXT NOT NULL" + ...
                ");");

            % Create index for faster queries
            sql.execute(...
                "CREATE INDEX idx_file_cache_size " + ...
                "ON file_cache(size);");
        end

        function dbOpen(obj,sql)
            %DBMIGRATE      Open and migrate database to a newer version if necessary.
            %

            result = sql.fetch('SELECT version FROM db_version');
            ver = result.version;
            
            if ver == obj.Version
                return
            end
        end
    end

    %% PUBLIC
    methods
        function obj = cache()
            %CACHE          Create a singleton instance of this class.
            %
            persistent singleton
            if isempty(singleton)
                obj.Instance = true;
                singleton = obj;
            else
                obj = singleton;
            end

            % create or connect sql database
            if isempty(obj.Sql)
                cfgdir = ana.os.paths("configdir");

                obj.Sql = ana.db.sqlite(File=cfgdir/"cache.db", ...
                    AutoCommit=true, ...
                    OnCreate=@(sql) obj.dbCreate(sql), OnOpen=@(sql) obj.dbOpen(sql));
            end
        end

        function delete(obj)
            %DELETE         Delete this object.
            if obj.Instance
                % nothing to be done
            end
        end
    end

    methods
        function result = get(obj,id)
            %GET    Get entry by file ID.
            %
            arguments
                obj ana.fs.cache
                id (1,1) string = ""
            end

            if isempty(id) || (strlength(id) == 0)
                result = obj.Sql.fetch(...
                    "SELECT * FROM file_cache");
            else
                result = obj.Sql.fetch(...
                    "SELECT * FROM file_cache WHERE id = ?", id);
            end
        end

        function result = add(obj,path,options)
            %ADD    Get entry by path or add.
            %
            arguments
                obj ana.fs.cache
                path (1,:)
                options.Folder (1,1) {mustBeNumericOrLogical} = false
            end

            path = ana.fs.path(path);
            if path(1) == "{storage}"
                id = path;
                thepath = path.resolve();
                assert(~isempty(thepath), "File not found: %s", path)
                path = thepath;
            else
                id = ana.fs.storage.as(path);
            end

            % retrieve existing entry
            result = obj.Sql.fetch(...
                "SELECT * FROM file_cache WHERE id = ?", fullfile(id));

            if ~isempty(result)
                return
            end

            % create cache path and entry
            usefolder = options.Folder || isfolder(path);
            cachefile = ana.os.paths("cachedir") / id;

            if usefolder
                mkdir(+cachefile);
            else
                newfolder = cachefile(1:end-1);
                if ~isfolder(newfolder)
                    mkdir(+newfolder);
                end

                % FIXME progress bar
                copyfile(+path,+cachefile);
            end

            obj.Sql.execute(...
                'INSERT OR REPLACE INTO file_cache (id, size, file) VALUES (?, 0, ?)', ...
                fullfile(id), +cachefile);

            result = obj.Sql.fetch(...
                "SELECT * FROM file_cache WHERE id = ?", fullfile(id));
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
%
% Development assistance:
%   DeepSeek (深度求索)
