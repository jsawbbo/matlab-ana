function [configdir,tmpdir,toolboxdir] = paths()
    %ANA.OS.PATHS   Get essential system-dependent paths.
    %
    %   configdir       System-dependent user-local configuration directory path.
    %   tmpdir          System-dependent temporary storage path.
    %   toolboxdir      Matlab-ana's toolbox directory.

    if ispc
        configdir = getenv('LOCALAPPDATA');                                 
        if isempty(configdir) % older than Vista
            configdir = getenv('APPDATA');
            if isempty(configdir)
                error('ANA:SYSTEM', 'Configuration directory could not be identified.');
            end
        end
    elseif isunix
        configdir = fullfile(getenv('HOME'), '.config');
    elseif ismac
        warning('Mac support is untested.');
        configdir = fullfile(getenv('HOME'), '.config');
    else
        error('Unsupported operating system')
    end

    configdir = fullfile(configdir, 'ana');
    if ~exist(configdir, 'dir')
        mkdir(configdir);
    end
    configdir = ana.fs.path(configdir);

    if ispc
        tmpdir = getenv('TEMP');
    elseif isunix
        tmpdir = '/tmp';
    elseif ismac
        tmpdir = getenv('TMPDIR');
    else
        error('Unsupported operating system')
    end

    tmpdir = fullfile(tmpdir, 'ana');
    if ~exist(tmpdir, 'dir')
        mkdir(tmpdir);
    end
    tmpdir = ana.fs.path(tmpdir);

    toolboxdir = fileparts(fileparts(which('ana.version')));
    toolboxdir = ana.fs.path(toolboxdir);

end
