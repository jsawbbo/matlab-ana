function resolved = collapse(path)
    %ANA.FS.ALIAS.COLLAPSE      FIXME
    %   
    arguments (Input)
        path ana.fs.path
    end
    
    aliases = ana.session().Aliases;
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
                return
            end
        end
    end
    found = false;
    res = path;
end