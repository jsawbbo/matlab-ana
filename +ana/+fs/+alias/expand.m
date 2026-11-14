function resolved = expand(path, options)
    %ana.fs.alias.expand        Expand aliases.
    %
    % FIXME
    % 
    % See: ana.fs.alias.collapse
    arguments 
        path ana.fs.path        % The path to expand.
        options.Aliases = []    % Aliases (internally used for unit tests).
    end

    if ~path.isalias()
        resolved = {path};
        return
    end

    if isempty(options.Aliases)
        aliases = ana.session().Aliases;
    else
        aliases = options.Aliases;
    end
    assert(isstruct(aliases) || isa(aliases,'ana.type.dict'), "Inavlid aliases type.")

    resolved = expand_helper(path, aliases, {});
end

function resolved = expand_helper(path, aliases, resolved)
    thealias = path.alias();
    
    if ~isfield(aliases, thealias)
        return
    end

    list = aliases.(thealias);
    for k = 1:numel(list)
        if isscalar(path)
            tmp = list{k};
        else
            tmp = list{k} / path(2:end);
        end
        if tmp.isalias()
            nres = numel(resolved);
            resolved = expand_helper(tmp, aliases, resolved);
            if nres == numel(resolved)
                warning("Alias '%s' is not declared.", tmp.alias())
                % FIXME this might be actually rather an error?
            end
        else
            resolved{end + 1} = tmp;
        end
    end
end

