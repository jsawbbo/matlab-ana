classdef level < int32
    %ana.log.level      Logging levels.
    enumeration
        ERROR   (4)    % Things that are definitely wrong
        WARN    (3)    % Things that might be wrong
        NOTICE  (2)    % Things that are noteworthy.
        STATUS  (1)    % Status message.
        INFO    (0)    % Informational message.
        DEBUG   (-1)   % Detailed information for debugging
        TRACE   (-2)   % Extremely detailed flow tracing
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
