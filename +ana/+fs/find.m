function res = find(path,pattern,options)
    %ana.fs.find        Find files in a directory.
    %   
    % Syntax:
    %    items = ana.fs.find(path, pattern);
    %    items = ana.fs.find(path, pattern, Depth=number);
    %
    % Search the directory 'path' for files with given regular expression
    % 'pattern'. The 'Depth' controls how deep directory traversal happens
    % (default: Inf).
    %
    % Returns a cell of paths.
    % 
    arguments (Input)
        path (1,:)
        pattern (1,:)
        options.Depth = Inf
    end

    path = ana.fs.path(path);
    res = cell(0,1);
    
    list = dir(+path);
    for i = 1:numel(list)
        item = list(i);
        cur = path / item.name;
        if item.isdir
            switch(item.name)
                case {'.','..'}
                otherwise
                    if options.Depth > 1
                        found = ana.fs.find(cur, pattern, Depth=options.Depth-1);
                        res = [res(:);found(:)];
                    end
            end
        else
            if regexp(item.name,pattern)
                res = [res(:);{cur}];
            end
        end
    end
end