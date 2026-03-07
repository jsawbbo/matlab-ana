function res = parse(s)
    %ana.file.yaml.parse    Parse a YAML string.
    %
    %See also: ana.file.yaml.koch.parse
    %
    %Note: This file internally uses Martin Koch's Matlab YAML package,
    %      released under the MIT License.
    arguments
        s (1, 1) string
    end

    res = ana.file.yaml.koch.parse(s,ConvertToArray=true);
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
