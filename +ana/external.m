function external(what)
    %ana.external       Helper for loading external dependencies.
    %
    %   This function initializes internally used libraries and 
    %   is only called from functions or classes that require said
    %   initialization.
    %

    arguments
        what = []
    end

    persistent externaldir

    if isempty(externaldir)
        externaldir = ana.os.paths('toolboxdir') / "external";
        externaldir = string(externaldir);
    end

    if isempty(what)
        known = ["snakeyaml"];
        for dep = known
            ana.external(dep)
        end
    else
        switch what
            case "snakeyaml"
                snakeyaml = fullfile(externaldir, 'snakeyaml-1.30.jar');
                if ~ismember(snakeyaml, javaclasspath('-dynamic'))
                    javaaddpath(snakeyaml);
                end
        end
    end
end

% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
