function res = load(filename)
    %ana.file.yaml.load     Load a YAML file.
    %
    %See also: ana.file.yaml.koch.parse
    %
    %Note: This file internally uses Martin Koch's Matlab YAML package,
    %      released under the MIT License.
    arguments
        filename (1, 1) string
    end

    content = string(fileread(string(filename)));
    res = ana.file.yaml.parse(content);
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
