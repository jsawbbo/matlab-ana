function save(filename,data,options)
    %ana.file.yaml.save     Save a YAML file.
    %
    %See also: ana.file.yaml.koch.dump
    %
    %Note: This file internally uses Martin Koch's Matlab YAML package,
    %      released under the MIT License.
    arguments
        filename (1, 1) string
        data
        options.Style {mustBeMember(options.Style, ["flow", "block", "auto"])} = "auto"
    end
    
    yamlString = blink.yaml.dump(data, Style=options.Style);

    folder = fileparts(filename);
    if strlength(folder) > 1 && ~isfolder(folder)
        mkdir(folder);
    end
    
    [fid, msg] = fopen(filename, "wt");
    if fid == -1
        error(msg)
    end
    fprintf(fid, "%s", yamlString);
    fclose(fid);
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
