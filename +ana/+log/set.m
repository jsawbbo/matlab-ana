function set(options)
    %ANA.LOG.SET         Set logger properties.
    %
    arguments 
        options.File = []
        options.Mode string = "w"
        options.Level = []
    end

    s = ana.state;

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


    %

    % doclose = isempty(filename);
    % 
    % if ~isempty(filename)
    %     if isstring(filename) || ischar(filename)
    %         if ~isempty(fd)
    %             fclose(fd);
    %         end
    % 
    %         fd = fopen(filename, options.Mode);
    %         if fd <= 2
    %             fd = [];
    %         end
    %     end
    % else
    %     if ~isempty(fd)
    %         fclose(fd);
    %     end
    %     fd = [];
    % end
    % 
end