classdef path < matlab.mixin.indexing.RedefinesParen
    %ana.fs.path    Canonical representation of a file path.
    %
    %   This class represents a file system path agnostic to operating system
    %   (Windows uses both forward and backward slashes).
    %
    %   To avoid machine-dependent paths, this class supports aliases (for details
    %   see <a href="matlab:help ana.fs.alias">ana.fs.alias</a>).
    %
    %   Examples:
    %       p = ana.fs.path("{home}/data/file.txt");
    %
    %       % Append path components
    %       p = ana.fs.path("~") / "data" / "file.txt";
    %
    %       % Obtain the canonical path without resolving aliases
    %       filename = string(p);
    %
    %       % Resolve aliases and locate an existing file
    %       filename = +p;
    %
    %       % Resolve a path even if the file does not exist
    %       filename = string(p.resolve(MustExist=false));
    %
    %   Note: The unary plus operator (+) resolves the path and returns its
    %   string representation. An error is raised if the path cannot be resolved.
    %
    %   See also: ana.fs.alias, ana.fs.path.resolve

    %TODO:
    % - Protect root/drive/share components in parenAssign and parenDelete.
    % - Ensure Parts never becomes empty.
    % - Validate assigned path components.

    %% CONSTANTS
    properties (Constant)
        separator = '/'                     % Canonical path separator.
        forbidden = '[^A-Za-z0-9._-]'       % Forbidden characters (regular expression) for "compatible" paths.
    end

    %% PROPERTIES
    properties (SetAccess=protected)
        Drive                               % Boolean value indicating that a Windows® drive letter is used.
        Parts                               % String array of path elements.
    end

    % meta-data
    properties
        Category ana.fs.category = ana.fs.category.local        % File category.
    end

    %% RedefinesParen
    methods
        function out = cat(~,varargin)
            out = varargin{1};
            for i = 2:numel(varargin)
                p = ana.fs.path(varargin{i});
                if ~p.isrelative()
                    error("ANA:runtime", "cannot concatenate non-relative paths.")
                end
                out.Parts = [out.Parts,p.Parts];
            end
        end

        function varargout = size(obj,varargin)
            [varargout{1:nargout}] = size(obj.Parts,varargin{:});
        end
    end

    methods (Static)
        function obj = empty()
            obj = ana.fs.path();
        end
    end

    methods (Access = protected)
        function varargout = parenReference(obj, indexOp)
            obj.Parts = obj.Parts.(indexOp(1));
            if isscalar(indexOp)
                varargout{1} = obj;
                return;
            end
            [varargout{1:nargout}] = obj.(indexOp(2:end));
        end

        function obj = parenAssign(obj,indexOp,varargin)
            if isempty(obj)
                obj = varargin{1};
            end
            if isscalar(indexOp)
                assert(nargin==3);
                rhs = varargin{1};
                obj.Parts.(indexOp) = rhs;
                return;
            end
            [obj.(indexOp(2:end))] = varargin{:};
        end

        function n = parenListLength(obj,indexOp,ctx)
            if numel(indexOp) <= 2
                n = 1;
                return;
            end
            containedObj = obj.(indexOp(1:2));
            n = listLength(containedObj,indexOp(3:end),ctx);
        end

        function obj = parenDelete(obj,indexOp)
            obj.Parts.(indexOp) = [];
        end
    end
    
    %% HELPERS
    methods (Hidden)
        function res = string(obj)
            res = fullfile(obj);
        end

        function disp(obj)
            fprintf('    "%s" (<a href="matlab:help ana.fs.path">ana.fs.path</a>)\n\n', string(obj));
        end
    end
    
    %% OPERATORS
    methods(Hidden)
        function res = eq(obj, other)
            %EQ Equality operator.
            %
            other = ana.fs.path(other);

            if numel(obj) ~= numel(other)
                res = false;
                return
            end

            res = all(obj.Parts == other.Parts);
        end

        function res = mrdivide(obj, part)
            %MRDIVIDE   Add a path part.
            %
            arguments
                obj ana.fs.path;
                part (1,:);
            end

            if ~isa(part, 'ana.fs.path')
                part = ana.fs.path(part);
            end

            if ~part.isrelative()
                error("ANA:runtime", "expected a relative path")
            end

            res = obj;
            res.Parts = [obj.Parts(1,:), part.Parts(1,:)];
        end

        function res = mldivide(obj, part)
            %MLDIVIDE   Add a path part.
            %
            res = obj.mrdivide(part);
        end

        function res = plus(obj,piece)
            %PLUS    Add piece to file name.
            %
            res = obj;
            res.Parts(end) = res.Parts(end) + string(piece);
        end

        function res = uplus(obj)
            %UPLUS  Equivalent of string() but with path resolution (see resolve()).
            %

            loc = obj.resolve();
            if isempty(loc)
                error("ana.fs.path:NoSuchLocation", "The file '%s' could not be resolved.", string(obj))
            end

            res = string(loc);
        end
    end

    %% PUBLIC
    methods
        function obj = path(pathname,options)
            %PATH Construct an instance of this class
            %
            % Syntax:
            %   obj = ana.fs.path()
            %   obj = ana.fs.path('path/to/file')
            %
            arguments
                pathname (1,:) = []
                options.Category = []
            end

            if isa(pathname, 'ana.fs.path')
                obj.Drive = pathname.Drive;
                obj.Parts = pathname.Parts;
                obj.Category = pathname.Category;
            else
                if isa(pathname, 'ana.type.url')
                    if ~isempty(pathname.Scheme)
                        switch (pathname.Scheme)
                            case 'share'
                                pathname = "//" + pathname.Host + "/" + pathname.Path;
                            case 'file'
                                pathname = pathname.Path;
                            otherwise
                                error("ANA:runtime", "not a filesystem path: '" + string(pathname) + "'")
                        end
                    else
                        pathname = string(pathname);
                    end
                end

                if isempty(pathname) || (strlength(pathname) == 0)
                    pathname = pwd();
                end
   
                obj.Parts = regexp(string(pathname),'[/\\]+','split');
                if isempty(obj.Parts{end})
                    obj.Parts = obj.Parts(1:end-1); % trailing path separator
                end

                if startsWith(pathname,'\\') || startsWith(pathname,'//')   % Windows share
                    obj.Parts = obj.Parts(2:end);
                    obj.Parts(1) = "//"+obj.Parts(1);
                end
                
                if regexp(obj.Parts(1), '^[a-zA-Z]:', 'once')
                    if strlength(obj.Parts(1)) > 2
                        obj.Parts = [strsplit(obj.Parts(1),":"),obj.Parts(2:end)];
                        obj.Parts(1) = obj.Parts(1)+":";
                    end
                    obj.Drive = true;
                    obj.Parts(1) = upper(obj.Parts(1));
                end
    
                if (numel(obj.Parts) == 2) && strlength(obj.Parts{end}) == 0
                    obj.Parts = obj.Parts(1);
                end
            end

            if ~isempty(options.Category)
                try 
                    obj.Category = ana.fs.category(options.Category);
                catch
                    warning('ana.fs.path:InvalidCategory', 'Provided category is not understood - ignoring.')
                end
            end
        end
    end

    methods
        function res = isfile(obj)
            %ISFILE   Check if path points to an existing file.
            %
            res = isfile(fullfile(obj));
        end

        function res = isfolder(obj)
            %ISFOLDER   Check if path points to an existing directory.
            %
            res = isfolder(fullfile(obj));
        end

        function res = isurl(obj)
            %ISURL      Check if path represents a server URL.
            %
            res = ~isempty(regexp(obj.Parts{1},"^([a-z]+):$", 'once'));
        end

        function res = isshare(obj)
            %ISSHARE    Check if path represents a network (i.e. CIFS) share.
            %
            res = startsWith(obj.Parts{1}, '//');
        end

        function res = isabsolute(obj)
            %ISABSOLUTE     Check if path is absolute.
            %
            arguments
                obj ana.fs.path;
            end

            if obj.Drive
                res = true;
            else
                res = isempty(obj.Parts{1}) || obj.isshare();
            end
        end

        function res = isrelative(obj)
            %ISRELATIVE   Check if path is relative.
            %
            arguments
                obj ana.fs.path;
            end
            
            res = ~obj.isabsolute();
        end

        function res = isalias(obj)
            %ISALIAS    Check if path uses an alias.
            %
            arguments
                obj ana.fs.path
            end

            res = obj.isrelative() && ...
                (obj.Parts{1} == "~" || ...
                    (startsWith(obj.Parts{1}, "{") && endsWith(obj.Parts{1}, "}")));
        end

        function str = drive(obj)
            %DRIVE   Get (Windows®) drive (if applicable).
            %
            arguments
                obj ana.fs.path;
            end
            
            if obj.Drive
                str = obj.Parts{1};
            else
                str = [];
            end
        end

        function res = alias(obj)
            %ALIAS  Get alias key (if applicable).
            %
            %See also: isalias
            %
            arguments
                obj ana.fs.path;
            end

            if obj.isalias()
                s = obj.Parts{1};
                if s == "~"
                    res = "home";
                else
                    res = extractBetween(string(s),2,strlength(s)-1);
                end
            else
                res = [];
            end
        end

        function str = fullfile(obj,varargin)
            %FULLFILE   Get full path as string.
            %
            %   The behavior is identical to MATLAB's 'fullfile'.
            %
            arguments
                obj ana.fs.path;
            end
            arguments (Repeating)
                varargin
            end

            full = obj;
            for i = 1:nargin-1
                full = full / varargin{i};
            end

            if isscalar(full.Parts) && ana.util.strempty(full.Parts{1})
                str = string(ana.fs.path.separator);
            else
                str = strjoin(full.Parts,obj.separator);
            end
        end

        function [path,filename,extension] = fileparts(obj)
            %FILEPARTS   Get file parts.
            %
            %   The behavior is identical to Matlab's 'fileparts'.
            %
            arguments
                obj ana.fs.path;
            end

            [path,filename,extension] = fileparts(string(obj));
        end

        function res = exist(obj,searchType)
            %EXIST   Check if file exists.
            %
            %   The behavior is identical to Matlab's 'exist'.
            %
            arguments
                obj ana.fs.path;
                searchType = [];
            end

            if isempty(searchType)
                res = exist(fullfile(obj)); %#ok<EXIST>
            else
                res = exist(fullfile(obj), searchType);
            end
        end

        function res = resolve(obj, options)

            %RESOLVE    Resolve a path to a file-system location.
            %
            %   RES = OBJ.RESOLVE() returns the first existing file or directory
            %   matching OBJ. Absolute paths are checked directly, alias paths
            %   are expanded, and relative paths are resolved against the current
            %   working directory.
            %
            %   RES = OBJ.RESOLVE(MustExist=false) also permits non-existing paths.
            %   If an existing location is found, it is returned. Otherwise, the
            %   first possible location is returned.
            %
            %   Options:
            %       MustExist   Require the resolved path to exist (default: true).
            %       Searchpath  Search path used for relative paths. If omitted,
            %                   the current working directory is used.
            %       Aliases     Alternative alias definitions (primarily for
            %                   unit testing).
            %
            %   Returns:
            %       An ana.fs.path object representing the resolved location,
            %       or [] if no suitable location can be resolved.
            %
            %   Notes:
            %   - Existing locations take precedence over non-existing candidates.
            %   - Alias expansions are considered in their defined order.
            %   - With MustExist=false, unresolved aliases still return [].
            %   - Searchpath.find() searches only for existing locations;
            %     MustExist=false does not change its behavior.
            %
            %   See also: ana.fs.alias.expand, ana.fs.alias.locate,
            %             ana.fs.searchpath.find
            arguments 
                obj ana.fs.path
                options.Searchpath = []     % A search path (ana.fs.searchpath).
                options.Aliases = []        % Aliases (internally used for unit tests).
                options.MustExist = true    % Resolved path must exist.
            end

            if obj.isabsolute()
                res = obj;
                if options.MustExist && ~(obj.isfile() || obj.isfolder())
                    res = [];
                end
            elseif obj.isalias()
                res = ana.fs.alias.locate(obj, Aliases=options.Aliases);
                if ~options.MustExist && isempty(res)
                    res = ana.fs.alias.expand(obj, Aliases=options.Aliases);
                    if isempty(res)
                        res = [];
                    else
                        res = res{1};
                    end
                end
            else % isrelative
                if isempty(options.Searchpath)
                    res = ana.fs.pwd() / obj;
                    if options.MustExist && ~(res.isfile() || res.isfolder())
                        res = [];
                    end
                else
                    res = options.Searchpath.find(obj);
                end
            end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
