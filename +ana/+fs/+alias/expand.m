function resolved = expand(path)
    %ANA.FS.ALIAS.EXPAND        FIXME
    %   
    arguments (Input)
        path ana.fs.path
    end
    if ~path.isalias()
        resolved = path;
        return
    end

    sess = ana.session();
    alias = path.alias();

    if ~sess.hasalias(alias)
        resolved = [];
    else
        [loc,~] = sess.getalias(alias);
        N = numel(loc);

        resolved = cell(1,N);

        for k = 1:N
            resolved{k} = loc(k)/path(2:end);
        end
    end
end