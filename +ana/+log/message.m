function message(level, fmt, varargin)
    %ana.log.message        Log a message
    %
    %   Detailed explanation goes here
    level = ana.log.level(level);

    if ana.log.g.level > level
        return
    end

    formattedMessage = sprintf(fmt, varargin{:});
    fprintf('[%s] %s\n', pad(string(level),6), formattedMessage);
end