function display(obj, name)
    %ana.type.display       Helper for 'display(obj)' method.
    %
    % Usage:
    %     function display(obj)
    %         ana.type.display(obj, inputname(1));
    %     end

    if ~isempty(name)
        fprintf('%s =\n\n', name);
    end

    fn = fieldnames(obj);
    if isempty(fn)
        fprintf('  <a href="matlab:help">%s</a> without contents.\n', class(obj));
        return
    end

    fprintf('  <a href="matlab:help">%s</a> with contents:\n', class(obj));
    disp(obj)
end