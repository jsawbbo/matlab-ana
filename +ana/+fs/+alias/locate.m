function resolved = locate(path,options)
    %ana.fs.alias.locate      Locate a file.
    %
    % FIXME
    %   
    % See: ana.fs.alias.expand
    arguments 
        path ana.fs.path            % The path to expand.
        options.Aliases = []        % Aliases (internally used for unit tests).
    end
    
    if ~path.isalias()
        resolved = [];
        return
    end

    tmp = ana.fs.alias.expand(path,Aliases=options.Aliases);

    for k = 1:numel(tmp)
        if tmp{k}.exist()
            resolved = tmp{k};
            return
        end
    end

    %TODO: 
    %- if the Aliases contain "remote" storage, it might be cachable
    %- check if file is in cache...

    resolved = [];
end