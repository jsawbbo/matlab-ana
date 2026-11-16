function res = getfield(var,key)
    %ana.util.getfield      Safely retrieve nested struct fields.
    %
    %   res = ana.util.getfield(var, ["meta","rules"])
    %
    % Returns [] if a field does not exist.

    key = string(key);
    res = var;

    for k = 1:numel(key)
        if ~isstruct(res) || ~isscalar(res) || ~isfield(res,key(k))
            res = [];
            return
        end

        res = res.(key(k));
    end
end