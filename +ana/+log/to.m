function varargout = to(filename,options)
    %ANA.LOG.TO         Log to a file.
    %
    % ana.log.to("log.txt")
    %
    %       This starts logging to the file "log.txt" in addition to the command line.
    %
    % ana.log.to([])
    %
    %       This stops logging to the previously opened file.
    % 
    arguments 
        filename = NaN
        options.Mode string = "w"
    end

    g = ana.log.g;
    if isstring(filename) || ischar(filename)
        % open log file
        FIXME()
    elseif isempty(filename)
        % close log file
    else
        % report file descriptor only
    end

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