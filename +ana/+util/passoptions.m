function result = passoptions(options,selection)
    %ana.util.passoptions   Equivalent of 'namedargs2cell' with field selection.
    %
    %   This function returns a cell array from struct entries, and,
    %   allows to select the fields.
    %
    %   Example:
    %
    %       function obj = derived_class(options)
    %           arguments
    %               options.Parent = []
    %               options.Value = 0
    %           end
    %
    %           poptions = ana.util.passoptions(options, {'Parent'})
    %           obj@parent_class(poptions{:});
    %       end
    %
    if nargin > 1
        result = {};
        fn = fieldnames(options);
        for i = 1:numel(fn)
            name = fn{i};
            if any(strcmp(selection,name))
                result{end+1} = name; %#ok<*AGROW>
                result{end+1} = options.(name);
            end
        end
    else
        result = namedargs2cell(options);
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
