function res = exception2string(e)
    %ana.util.exception2string    Convert MATLAB exception to a formatted string.
    %   
    arguments
        e (1,1) 
    end

    res = string(e.message);
    res = res + newline + "[" + string(e.identifier) + "]";

    if isempty(e.stack)
        return
    end

    % get location from stack
    file = e.stack(1).file;
    name = e.stack(1).name;
    line = e.stack(1).line;

    try
        % toolbox
        toolboxdirs = split(path(), pathsep);
        match = cellfun(@(item) startsWith(file,[item filesep]), toolboxdirs);
        toolboxdirs = toolboxdirs(match);

        toolbox = [];
        if ~isempty(toolboxdirs)
            [~, idx] = max(strlength(toolboxdirs));
        
            toolbox = ana.fs.path(toolboxdirs{idx});
        end
    
        % file in toolbox
        if ~isempty(toolbox)
            file = ana.fs.path(file);
            file = file(numel(toolbox)+1:end);
            file = string(file);
        end
    catch
        toolbox = [];
    end

    % output
    res = res + newline + "in";
    res = res + newline + "   function: " + string(name);

    if ~isempty(toolbox)
        res = res + newline + "       path: " + string(toolbox);
    end

    res = res + newline + "       file: " + string(file);
    res = res + newline + "       line: " + string(line);
end