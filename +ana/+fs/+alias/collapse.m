function resolved = collapse(path,options)
    %ana.fs.alias.collapse      Collapse a path to its alias form.
    %
    % FIXME
    % 
    % See: ana.fs.alias.expand
    arguments (Input)
        path ana.fs.path        % The path to collapse.
        options.Aliases = []    % Aliases (internally used for unit tests).
    end
    
    if isempty(options.Aliases)
        aliases = ana.session().Aliases;
    else
        aliases = options.Aliases;
    end
    assert(isstruct(aliases) || isa(aliases,'ana.type.dict'), "Inavlid aliases type.")

    names = keys(aliases);

    found = true;
    resolved = path;
    while found
        [resolved,found] = collapse_helper(resolved,names,aliases);
    end
end

function [res,found] = collapse_helper(path,names,aliases)
    for k = 1:numel(names)
        name = names(k);
        alias = aliases.(name);

        for l = 1:numel(alias)
            location = ana.fs.path(alias(l).location);
    
            n = numel(location);
            found = (n <= numel(path)) && all(location == path(1:n));
            if found
                res = ("{"+name+"}") / path(n+1:end);
                res.Category = ana.fs.category.local;
                % (collapsed paths are always represented as local, 
                % they will inherit the category on expansion!)
                return
            end
        end
    end
    found = false;
    res = path;
end