function set(options)
    %ANA.LOG.SET         Set logger properties.
    %
    arguments 
        options.File = []               % The file name.
        options.Mode string = "w"       % File open mode.
        options.Level = []              % Log-level threshold.
    end

    s = ana.session;

    % log level
    if ~isempty(options.Level)
        s.LogLevel = ana.log.level(options.Level);
    end

    % log file
    if ~isempty(options.File)
        filename = options.File;

        if isstring(filename) || ischar(filename)
            % open log file
            s.LogFile = fopen(filename,options.Mode);
        else
            % close file
            try 
                fclose(s.LogFile);
            catch
            end
            s.LogFile = [];
        end
    end
end