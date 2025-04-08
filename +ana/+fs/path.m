classdef path
    %ANA.FS.PATH Filesystem path.
    %
    %   Canonical representation of a filesystem path.
    %

    properties (SetAccess = protected)
        Drive
        Parts
    end

    properties(Constant,Hidden)
        separator = '/'
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
    
                obj.Parts = regexp(char(pathname),'[/\\]','split');
                obj.Drive = ~isempty(regexp(obj.Parts{1}, '^[a-zA-Z]:$', 'once'));
    
                if (numel(obj.Parts) == 2) && strlength(obj.Parts{end}) == 0
                    obj.Parts = obj.Parts(1);
                end           
            end
        end

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
            res = obj.mrdivide(part);
        end
    end

    methods
        
        function res = isfile(obj)
            %ISFILE   Check if path points to an existing file.
            res = isfile(obj.full());
        end

        function res = isfolder(obj)
            %ISFOLDER   Check if path points to an existing directory.
            res = isfolder(obj.full());
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

        function str = full(obj)
            %FULL   Get full path as string.
            %
            arguments
                obj ana.fs.path;
            end

            str = strjoin(obj.Parts,obj.separator);
        end

        function [path,filename,extension] = parts(obj)
            %PARTS   Get file parts as string.
            arguments
                obj ana.fs.path;
            end

            path = strjoin(obj.Parts(1:end-1),obj.separator);
            filename = obj.Parts{end};
            extension = regexp(filename, '[.][^.]+$', 'match');
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

