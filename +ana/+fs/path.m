classdef path
    %ana.fs.path    Canonical representation of a file path.
    %
    %   To enable operating system indepent file paths, and, as well, storage layouts,
    %   ...FIXME...
    %
    %   FIXME: storage layout -> search path "{storage}"
    %
    %TODO:
    %   Samba shares starting with "\\" (or "//").
    %
    %See also: FIXME search path

    properties (SetAccess=protected)
        Drive   % Boolean value indicating that a Windows® drive letter is used.
        Parts   % String array of path elements.
    end

    properties (Constant)
        separator = '/' % Canonical path separator.
    end
    
    methods (Hidden)
        function res = string(obj)
            res = fullfile(obj);
        end

        function disp(obj)
            fprintf('    "%s" (<a href="matlab:help ana.fs.path">ana.fs.path</a>)\n\n', string(obj));
        end
    end
   
    methods
        function obj = path(pathname)
            %PATH Construct an instance of this class
            %
            %Syntax:
            %   obj = ana.fs.path()
            %   obj = ana.fs.path('path/to/file')
            %
            arguments
                pathname (1,:) = []
            end

            if isa(pathname, 'ana.fs.path')
                obj.Drive = pathname.Drive;
                obj.Parts = pathname.Parts;
            else
                if isempty(pathname) || (strlength(pathname) == 0)
                    pathname = pwd();
                end
    
                obj.Parts = regexp(string(pathname),'[/\\]','split');
                obj.Drive = ~isempty(regexp(obj.Parts{1}, '^[a-zA-Z]:$', 'once'));
    
                if (numel(obj.Parts) == 2) && strlength(obj.Parts{end}) == 0
                    obj.Parts = obj.Parts(1);
                end           
            end
        end
    end

    methods(Hidden)
        function res = mrdivide(obj, part)
            %MRDIVIDE   Add a path part.
            arguments
                obj ana.fs.path;
                part (1,:);
            end

            if ~isa(part, 'ana.fs.path')
                part = ana.fs.path(part);
            end
           
            if ~part.isrelative()
                error('ANA:FS:RELATIVE', 'path to append must be relative')
            end

            res = obj;
            res.Parts = [obj.Parts(1,:), part.Parts(1,:)];
        end

        function res = mldivide(obj, part)
            %MLDIVIDE   Add a path part.
            res = obj.mrdivide(part);
        end

        function res = plus(obj,piece)
            %PLUS    Add piece to file name.
            %
            res = obj;
            res.Parts(end) = res.Parts(end) + string(piece);
        end
    end

    methods
        function res = isfile(obj)
            %ISFILE   Check if path points to an existing file.
            res = isfile(fullfile(obj));
        end

        function res = isfolder(obj)
            %ISFOLDER   Check if path points to an existing directory.
            res = isfolder(fullfile(obj));
        end

        function res = isrelative(obj)
            %ISRELATIVE   Check if path is relative.
            %
            arguments
                obj ana.fs.path;
            end
            
            if obj.Drive
                res = false;
            else
                res = ~isempty(obj.Parts{1});
            end
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

        function str = fullfile(obj,varargin)
            %FULLFILE   Get full path as string.
            %
            %   The behavior is identical to Matlab's 'fullfile'.
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

            str = strjoin(full.Parts,obj.separator);
        end

        function [path,filename,extension] = fileparts(obj)
            %FILEPARTS   Get file parts.
            %
            %   The behavior is identical to Matlab's 'fileparts'.
            %
            arguments
                obj ana.fs.path;
            end

            path = strjoin(obj.Parts(1:end-1),obj.separator);
            filename = obj.Parts{end};
            extension = regexp(filename, '[.][^.]+$', 'match');
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

        % function rel = relative(obj, other)
        %     %PARTS   Get file parts as string.
        %     arguments
        %         obj ana.fs.path;
        %         other (1,1);
        %     end
        % 
        % 
        % end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later

