function save(filename,data,options)
    %ana.file.yaml.save     Save a YAML file.
    %
    % See also: ana.file.yaml.dump
    %
    
    arguments
        filename (1, :) 
        data
        options.Style {mustBeMember(options.Style, ["flow", "block", "auto"])} = "block"
    end
    
    filename = ana.fs.path(filename);
    yamlString = ana.file.yaml.dump(data, Style=options.Style);

    folder = fileparts(filename);
    if strlength(folder) > 1 && ~isfolder(folder)
        mkdir(folder);
    end
    
    [fid, msg] = fopen(+filename, "wt");
    if fid == -1
        error("ANA:runtime", msg)
    end
    fprintf(fid, "%s", yamlString);
    fclose(fid);
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% Copyright (c) 2022 Martin Koch
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Martin Koch
%   Jürgen "George" Sawinski
%
% Originally licensed under MIT License, see accompanying file in this folder.
