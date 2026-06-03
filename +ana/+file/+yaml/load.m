function res = load(filename)
    %ana.file.yaml.load     Load a YAML file.
    %
    % See also: ana.file.yaml.parse
    %

    arguments
        filename (1, :)
    end

    filename = ana.fs.path(filename);
    content = string(fileread(string(filename)));
    res = ana.file.yaml.parse(content);
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% Copyright (c) 2022 Martin Koch
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Martin Koch
%   Jürgen "George" Sawinski
%
% Originally licensed under MIT License, see accompanying file in this folder.
