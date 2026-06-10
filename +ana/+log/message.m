function message(level, fmt, varargin)
    %ana.log.message        Log a message
    %
    %   FIXME
    %
    level = ana.log.level(level);

    if ana.log.g.level > level
        return
    end

    formattedMessage = sprintf(fmt, varargin{:});
    fprintf('[%s] %s\n', pad(string(level),6), formattedMessage);

    fd = ana.state().LogFile;
    if ~isempty(fd)
        try
            fprintf(fd, '[%s] %s\n', pad(string(level),6), formattedMessage);
        catch
        end
    end
end