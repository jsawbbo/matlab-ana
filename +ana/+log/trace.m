function trace(fmt,varargin)
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
