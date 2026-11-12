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
        alias = names(k);
        location = ana.fs.path(aliases.(alias).location);

        n = numel(location);
        found = all(location == path(1:n));
        if found
            res = ("{"+alias+"}") / path(n+1:end);
            return
        end
    end
    res = path;
end