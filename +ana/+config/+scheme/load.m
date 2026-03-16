function sch = load(file)
    %ana.config.scheme.load     Load a scheme from file.
    %
    %   Schemes, as described in '{toolboxdir}/scheme/README.md' ...FIXME...
    persistent toolboxdir

    if isempty(toolboxdir)
        toolboxdir = ana.os.paths('toolboxdir');
    end
    
    % struct
    if isstruct(file)
        sch = convert(file);
        return
    end
    
    % schema name
    path = toolboxdir / "scheme" / (string(file) + ".yml");
    if isfile(path)
        sch = convert(ana.file.yaml.load(path));
        return
    end

    error("could not find scheme")
end

function S = convert(S)
    % create "standard" fields
    if ~isfield(S,"meta"), S.meta = []; end
    if ~isfield(S,"content"), S.content = []; return; end

    % standardize "content" field
    if iscell(S.content)
        getentry = @(i) S.content{i};
    else
        getentry = @(i) S.content(i);
    end

    content = struct(key={},type={},meta={},content={});
    for i = 1:numel(S.content)
        content(i) = convert(getentry(i));
    end
    S.content = content;
end
