function init()
    %ANA.INIT Initialize "ANA".
    %
    %   This function initializes internally used search paths and 
    %   is only called from functions or classes that require said
    %   initialization.
    %
    persistent version

    if ~ischar(version) | ~strcmp(ana.version(),version)
        mfile = mfilename('fullpath');

        init_snakeyaml(mfile);

        version = ana.version();
    end
end

function init_snakeyaml(mfile)
    folder = fullfile(fileparts(mfile), '..', 'external', 'snakeyaml-1.30.jar');
    if ~ismember(folder, javaclasspath('-dynamic'))
        javaaddpath(folder);
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
