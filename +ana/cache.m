classdef cache
    %ANA.CACHE          File and meta-data cache.
    %   

    %% PROPERTIES
    properties (SetAccess = protected)
    end

    properties (Access = private)
        Instance = false
        Sql = []
    end

    properties(Constant,Hidden)
        Version = 1
    end

    %% DATABASE 
    methods(Access = protected)
        function dbCreate(obj)
            % create version table
            obj.Sql.execute(sprintf(...
                "CREATE TABLE db_version (" + ...
                "    version INTEGER PRIMARY KEY" + ...
                ");",obj.Version));

            obj.Sql.execute(sprintf(...
                "INSERT INTO db_version (version) VALUES (%d);", obj.Version));

            % Create file cache table
            obj.Sql.execute(...
                "CREATE TABLE file_cache (" + ...
                "    id TEXT PRIMARY KEY," + ...
                "    size BIGINT," + ...
                "    file TEXT NOT NULL" + ...
                ");");

            % Create index for faster queries
            obj.Sql.execute(...
                "CREATE INDEX idx_file_cache_size " + ...
                "ON file_cache(size);");
        end

        function dbMigrate(obj,from,to)
            if from == to
                return
            end
        end

        function query = dbStatement(obj, query, varargin)
            %DBSTATEMENT Safely assemble a SQL statement by replacing ? with escaped values
            %
            % Input:
            %   query - SQL query string with ? placeholders
            %   varargin - Values to replace ? placeholders (in order)
            %
            % Output:
            %   query - Assembled SQL string with values properly escaped
            %
            % Example:
            %   query = dbStatement(obj, "SELECT * FROM file_cache WHERE id = ?", "video_123")
            %   % Returns: "SELECT * FROM file_cache WHERE id = 'video_123'"
            
            % If no parameters, return as-is
            if isempty(varargin)
                query = string(query);
                return;
            end
            
            % Convert to string
            queryStr = string(query);
            
            % Validate placeholder count
            placeholderCount = count(queryStr, '?');
            numParams = length(varargin);
            
            if placeholderCount ~= numParams
                error('Parameter count mismatch: %d placeholders but %d parameters provided', ...
                    placeholderCount, numParams);
            end
            
            % Replace placeholders (process in reverse to avoid issues)
            % Split the query by '?'
            parts = split(queryStr, '?');

            % Rebuild with escaped values
            queryStr = parts{1};
            for i = 1:numParams
                escapedValue = obj.escapeSQL(varargin{i});
                queryStr = queryStr + escapedValue + parts{i+1};
            end

            query = queryStr;
        end
        
        function escaped = escapeSQL(obj, value)
            %ESCAPESQL Escape a value for safe SQL insertion
            
            % Handle empty/NULL
            if isempty(value)
                escaped = 'NULL';
                return;
            end
            
            % Handle different types
            if ischar(value) || isstring(value)
                % String: escape single quotes by doubling them
                str = string(value);
                str = strrep(str, "'", "''");
                escaped = "'" + str + "'";
                
            elseif isnumeric(value)
                % Numeric: direct conversion
                if isscalar(value)
                    if isnan(value) || isinf(value)
                        escaped = 'NULL';
                    else
                        escaped = string(value);
                    end
                else
                    % Array: format as comma-separated list
                    escaped = "(" + join(string(value), ", ") + ")";
                end
                
            elseif islogical(value)
                % Logical: convert to 1/0
                escaped = string(double(value));
                
            elseif isdatetime(value)
                % Datetime: format as SQLite datetime
                escaped = "'" + datestr(value, 'yyyy-mm-dd HH:MM:SS') + "'";
                
            elseif isduration(value)
                % Duration: convert to seconds
                escaped = string(seconds(value));
                
            elseif iscategorical(value)
                % Categorical: convert to string and escape
                str = string(value);
                str = strrep(str, "'", "''");
                escaped = "'" + str + "'";
                
            elseif iscell(value)
                % Cell array: escape each element
                if isscalar(value)
                    escaped = obj.escapeSQL(value{1});
                else
                    escaped = "(";
                    for i = 1:length(value)
                        if i > 1
                            escaped = escaped + ", ";
                        end
                        escaped = escaped + obj.escapeSQL(value{i});
                    end
                    escaped = escaped + ")";
                end
                
            else
                % Fallback: convert to string and escape
                str = string(value);
                str = strrep(str, "'", "''");
                escaped = "'" + str + "'";
            end
            
            escaped = string(escaped);
        end        
           
        function result = fetch(obj,fmt,varargin)
            query = obj.dbStatement(fmt,varargin{:});

            maxRetries = 10;
            baseDelay = 0.01;
            maxDelay = 5.0;

            for attempt = 1:maxRetries
                try
                    result = obj.Sql.fetch(query);
                    return;
                catch me
                    if contains(ME.message, 'busy') || ...
                            contains(ME.message, 'locked') || ...
                            contains(ME.message, 'database is locked')

                        % Calculate delay with exponential backoff
                        delay = min(baseDelay * (2^(attempt-1)), maxDelay);

                        % Add small random jitter to avoid collisions
                        delay = delay * (0.8 + 0.4 * rand());

                        fprintf('Database busy, retrying in %.3f seconds (attempt %d/%d)\n', ...
                            delay, attempt, maxRetries);

                        pause(delay);

                    else
                        % Other error - rethrow
                        rethrow(ME);
                    end
                end
            end
        end

        function execute(obj,fmt,varargin)
            query = obj.dbStatement(fmt,varargin{:});

            maxRetries = 10;
            baseDelay = 0.01;
            maxDelay = 5.0;

            for attempt = 1:maxRetries
                try
                    obj.Sql.execute(query);
                    return;
                catch me
                    if contains(ME.message, 'busy') || ...
                            contains(ME.message, 'locked') || ...
                            contains(ME.message, 'database is locked')

                        % Calculate delay with exponential backoff
                        delay = min(baseDelay * (2^(attempt-1)), maxDelay);

                        % Add small random jitter to avoid collisions
                        delay = delay * (0.8 + 0.4 * rand());

                        fprintf('Database busy, retrying in %.3f seconds (attempt %d/%d)\n', ...
                            delay, attempt, maxRetries);

                        pause(delay);

                    else
                        % Other error - rethrow
                        rethrow(ME);
                    end
                end
            end
        end
    end

    %% PUBLIC
    methods
        function obj = cache()
            %CACHE          Create a singleton instance of this class.
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
                dbfile = cfgdir/"cache.db";

                dbexists = isfile(dbfile);

                % create or connect
                if dbexists
                    obj.Sql = sqlite(+dbfile,"connect");
                else
                    obj.Sql = sqlite(+dbfile,"create");
                    obj.dbCreate();
                end

                % pragmas
                obj.Sql.AutoCommit = 'off';
                obj.Sql.execute("PRAGMA journal_mode = WAL;");
                obj.Sql.execute("PRAGMA foreign_keys = ON;");
                obj.Sql.execute('PRAGMA synchronous = NORMAL;');

                obj.Sql.execute('PRAGMA busy_timeout = 5000;');
                    
                % check or create db
                obj.Sql.AutoCommit = 'on';
                if dbexists
                    result = obj.fetch('SELECT version FROM db_version');
                    obj.dbMigrate(result.version, obj.Version);
                end
            end
        end

        function delete(obj)
            %DELETE         Delete this object.
            if obj.Instance
                close(obj.Sql);
            end
        end
    end

    methods
        function result = get(obj,id)
            %GET Get entry by file ID.
            arguments
                obj ana.cache
                id (1,1) string
            end

            result = obj.fetch(...
                "SELECT * FROM file_cache WHERE id = ?", id);
        end

        function result = add(obj,path,options)
            %ADD Get entry by path or add.
            arguments
                obj ana.cache
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
            result = obj.fetch(...
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

            obj.execute(...
                'INSERT OR REPLACE INTO file_cache (id, size, file) VALUES (?, 0, ?)', ...
                fullfile(id), +cachefile);

            result = obj.fetch(...
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
