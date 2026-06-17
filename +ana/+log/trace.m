function trace(fmt,varargin)
    %ana.log.trace      Log trace (with stack info).
    %
    % See also: ana.log.level, ana.log.message, ana.log.set

    if ana.log.g.level > ana.log.level.TRACE
        return
    end

    % user message
    msg = string(sprintf(fmt,varargin{:}));

    % debug trace
    st = dbstack(1);
    for i = 1:length(st)
        msg = msg + ...
            sprintf("\n\n    %-3d file: %s\n        name: %s\n        line: %d", ...
                i, ...
                st(i).file, st(i).name, st(i).line);
    end

    ana.log.message('trace',msg);
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
