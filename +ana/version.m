function res = version(what)
    %ANA.VERSION    Get matlab-ana version info.
    %
    arguments
        what (1,1) string = '';
    end

    RELEASE = '0.0.0';

    switch(what)
        case 'string'
            res = RELEASE;
        otherwise
            res = ana.util.version(RELEASE);
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski

