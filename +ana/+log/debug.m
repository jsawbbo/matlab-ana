function debug(fmt,varargin)
    %ana.log.debug      Log debug message.
    %
    % See also: ana.log.level, ana.log.message, ana.log.set

    ana.log.message('debug',fmt,varargin{:});
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
