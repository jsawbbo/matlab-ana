function s = paths(what)
    %ANA.OS.PATHS   Get essential system-dependent paths.
    %
    %Syntax:
    %   s = ana.os.paths()
    %
    %   returns: a structure with
    %       configdir       System-dependent user-local configuration directory path.
    %       tmpdir          System-dependent temporary storage path.
    %       toolboxdir      Matlab-ana's toolbox directory.
    %
    %   s = ana.os.paths(what)
    %
    %   where
    arguments
        what = [];
    end

    if isempty(what)
        s = struct();
        s.configdir = ana.os.paths('configdir');
        s.tmpdir = ana.os.paths('tmpdir');
        s.toolboxdir = ana.os.paths('toolboxdir');
    else
        switch(what)
            case 'configdir'
                if ispc
                    s = getenv('LOCALAPPDATA');                                 
                    if isempty(s) % older than Vista
                        s = getenv('APPDATA');
                        if isempty(s)
                            error('ANA:SYSTEM', 'Configuration directory could not be identified.');
                        end
                    end
                elseif isunix
                    s = fullfile(getenv('HOME'), '.config');
                elseif ismac
                    warning('Mac support is untested.');
                    s = fullfile(getenv('HOME'), '.config');
                else
                    error('Unsupported operating system')
                end
            
                s = fullfile(s, 'ana');
                if ~exist(s, 'dir')
                    mkdir(s);
                end
                s = ana.fs.path(s);

            case 'tmpdir'
                if ispc
                    s = getenv('TEMP');
                elseif isunix
                    s = '/tmp';
                elseif ismac
                    s = getenv('TMPDIR');
                else
                    error('Unsupported operating system')
                end
            
                s = fullfile(s, 'ana');
                if ~exist(s, 'dir')
                    mkdir(s);
                end
                s = ana.fs.path(s);

                
            case 'toolboxdir'
                s = fileparts(fileparts(which('ana.version')));
                s = ana.fs.path(s);

        end
    end

end
