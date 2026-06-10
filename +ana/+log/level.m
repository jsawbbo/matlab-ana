classdef level < int32
    %ana.log.level      Logging levels.
    enumeration
        ERROR   (3)    % Things that are definitely wrong
        WARN    (2)    % Things that might be wrong
        NOTICE  (1)    % Things that are noteworthy.
        INFO    (0)    % Normal operational messages
        DEBUG   (-1)   % Detailed information for debugging
        TRACE   (-2)   % Extremely detailed flow tracing
    end
end