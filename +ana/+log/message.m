function message(level, fmt, varargin)
    %ana.log.message        Log a message
    %
    %   FIXME
    %
    % For colored output, install the <a href="https://www.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-command-window">cprintf</a> toolbox.
    %
    level = ana.log.level(level);

    if ana.state().LogLevel > level
        return
    end

    formattedMessage = sprintf(fmt, varargin{:});
    formattedMessage = sprintf('[%s] %s\n', pad(string(level),6), formattedMessage);

    try
        switch(level)
            case ana.log.level.ERROR
                cprintf('*red',formattedMessage);
            case ana.log.level.WARN
                cprintf('*orange',formattedMessage);
            case ana.log.level.NOTICE
                cprintf('*Text',formattedMessage);
            case ana.log.level.STATUS
                cprintf('green',formattedMessage);
            case ana.log.level.INFO
                cprintf('Text',formattedMessage);
            otherwise
                fprintf(formattedMessage);
        end
    catch
        fprintf(formattedMessage);
    end

    fd = ana.state().LogFile;
    if ~isempty(fd)
        try
            fprintf(fd, formattedMessage);
        catch
        end
    end
end