function resolved = find(path)
    %ANA.FS.ALIAS.FIND      FIXME
    %   
    arguments (Input)
        path ana.fs.path
    end
    
    tmp = ana.fs.alias.expand(path);

    for k = 1:numel(tmp)
        if tmp{k}.exist()
            resolved = tmp{k};
            return
        end
    end

    resolved = [];
end