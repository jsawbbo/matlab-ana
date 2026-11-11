classdef sqlite < ana.db.sql
    %ANA.DB.SQLITE      SQLite database handling.
    %

    %% PROPERTIES
    properties (Access = private)
        Sql = []
    end

    %% CONSTRUCTOR
    methods
        function obj = sqlite(options)
            %SQLITE     Create an instance of this class.
            %
            % Syntax:
            %   obj = ana.db.sqlite();
            %   obj = ana.db.sqlite(options...);
            %
            % Options:
            %   File <file-name>            Open or create data-base with given file name.
            %   AutoCommit <boolean>        Auto-commit insertions (default: true).
            %   OnCreate <function>         Execute function when database is created.
            %   OnOpen <function>           Execute function when database exists.
            %
            arguments
                options.File (1,1) string = ''
                options.AutoCommit = true
                options.OnCreate = @(sql) []
                options.OnOpen = @(sql) []
            end

            if ~isempty(options.File) && (strlength(options.File) > 0)
                obj.connect(options.File, ...
                    AutoCommit=options.AutoCommit, ...
                    OnCreate=options.OnCreate, OnOpen=options.OnOpen);
            end
        end

        function delete(obj)
            %DELETE     Destroy object.
            %
            if ~isempty(obj.Sql) && isopen(obj.Sql)
                close(obj.Sql);
            end
        end
    end

    %% PUBLIC
    methods
        function exists = connect(obj, dbfile, options)
            %CONNECT    Connect to SQL database.
            %
            % Syntax:
            %   exists = obj.connect(filename);
            %   exists = obj.connect(filename, options...);
            %
            % Options:
            %   AutoCommit <boolean>        Auto-commit insertions (default: true).
            %
            % Returns:
            %   true if database existed, false if it was created.
            %
            arguments
                obj ana.db.sqlite
                dbfile (1,1) 
                options.AutoCommit = true
                options.OnCreate = @(obj) []
                options.OnOpen = @(obj) []
            end
            
            dbfile = ana.fs.path(dbfile);
            exists = isfile(dbfile);

            % create or connect
            if exists
                obj.Sql = sqlite(+dbfile,"connect");
            else
                obj.Sql = sqlite(+dbfile,"create");
            end

            % pragmas
            obj.Sql.AutoCommit = 'off';
            obj.Sql.execute("PRAGMA journal_mode = WAL;");
            assert(strcmpi(obj.Sql.fetch("PRAGMA journal_mode;").journal_mode, "WAL"));

            obj.Sql.execute("PRAGMA foreign_keys = ON;");
            assert(obj.Sql.fetch("PRAGMA foreign_keys;").foreign_keys == true);

            obj.Sql.execute('PRAGMA synchronous = NORMAL;');
            assert(obj.Sql.fetch("PRAGMA synchronous;").synchronous == 1);

            obj.Sql.execute('PRAGMA busy_timeout = 1000;');
            assert(obj.Sql.fetch("PRAGMA busy_timeout;").timeout == 1000);

            % settings
            if options.AutoCommit
                obj.Sql.AutoCommit = 'on';
            end

            % "on"...
            if exists
                options.OnOpen(obj);
            else
                options.OnCreate(obj);
            end
        end

        function result = fetch(obj, fmt, varargin)
            %FETCH      Query SQL database (with placeholder format).
            %

            query = obj.statement(fmt,varargin{:});

            maxRetries = 10;
            baseDelay = 0.01;
            maxDelay = 1.0;

            for attempt = 1:maxRetries
                try
                    result = obj.Sql.fetch(query);
                    return;
                catch me
                    if attempt == maxRetries
                        rethrow(me);
                    end

                    if contains(me.message, 'busy') || ...
                            contains(me.message, 'locked') || ...
                            contains(me.message, 'database is locked')

                        % Calculate delay with exponential backoff
                        delay = min(baseDelay * (2^(attempt-1)), maxDelay);

                        % Add small random jitter to avoid collisions
                        delay = delay * (0.8 + 0.4 * rand());

                        fprintf('Database busy, retrying in %.3f seconds (attempt %d/%d)\n', ...
                            delay, attempt, maxRetries);

                        pause(delay);

                    else
                        % Other error - rethrow
                        rethrow(me);
                    end
                end
            end
        end

        function execute(obj,fmt,varargin)
            %EXECUTE    Execute SQL command (with placeholder format).
            %

            query = obj.statement(fmt,varargin{:});

            maxRetries = 10;
            baseDelay = 0.01;
            maxDelay = 5.0;

            for attempt = 1:maxRetries
                try
                    obj.Sql.execute(query);
                    return;
                catch me
                    if attempt == maxRetries
                        rethrow(me);
                    end

                    if contains(me.message, 'busy') || ...
                            contains(me.message, 'locked') || ...
                            contains(me.message, 'database is locked')

                        % Calculate delay with exponential backoff
                        delay = min(baseDelay * (2^(attempt-1)), maxDelay);

                        % Add small random jitter to avoid collisions
                        delay = delay * (0.8 + 0.4 * rand());

                        fprintf('Database busy, retrying in %.3f seconds (attempt %d/%d)\n', ...
                            delay, attempt, maxRetries);

                        pause(delay);

                    else
                        % Other error - rethrow
                        rethrow(me);
                    end
                end
            end

            function commit(obj)
                %COMMIT     Commit transaction.
                %
                commit(obj.Sql);
            end

            function rollback(obj)
                %ROLLBACK   Rollback transaction.
                %
                rollback(obj.Sql);
            end
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
