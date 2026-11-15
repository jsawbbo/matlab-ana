function [valid, reason] = validate(value, type, rules)
    %VALIDATE       Config value validation in leafs.
    %
    % This function validates values in the configuration based on the 
    % meta information given in a scheme.
    %
    % Syntax:
    %   [valid, reason] = validate(value, rules)
    %
    % with the actual value to be assigned, it's expected type and the
    % validation rules ("validate" field under "meta" in the scheme).
    % 
    % Validation rules:
    %
    %   FIXME
    %
    %See: ana.config.node.leaf
    valid = true;
    reason = [];

    if isempty(type) || strcmp(type,"*")
        type = ana.config.scheme.typeid(value);
    end

    switch (type)
        case {"integral","numeric"}
            if isfield(rules, "limits")
                if isfield(rules.limits, "min") && any(value < rules.limits.min, "all")
                    valid = false;
                    reason = "Value is below the minimum.";
                    return
                end
                if isfield(rules.limits, "max") && any(value > rules.limits.max, "all")
                    valid = false;
                    reason = "Value exceeds the maximum.";
                    return
                end
            end

        case {"category"}
            assert(isstruct(rules), "Expected rules to be a (1,:) struct.")

            for k = 1:numel(rules)
               if strcmp(rules(k).value, value)
                   return
               end
            end

            valid = false;
            reason = sprintf("Invalid category '%s'.", string(value));
        %TODO:
        %- case {"string"}
        otherwise
            % ignored
    end
end