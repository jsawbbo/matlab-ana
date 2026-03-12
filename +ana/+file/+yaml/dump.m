function res = dump(data,options)
    %ana.file.yaml.dump     Dump to YAML formatted string.
    %
    %See also: ana.file.yaml.koch.dump
    %
    %Note: This file internally uses Martin Koch's Matlab YAML package,
    %      released under the MIT License.
    %
    %TODO:
    %- add more dumper options (see
    %  https://www.javadoc.io/doc/org.yaml/snakeyaml/1.19/org/yaml/snakeyaml/DumperOptions.html)
    arguments
        data
        options.Style {mustBeMember(options.Style, ["flow", "block", "auto"])} = "block"
    end

    koch = convertStructureArrays(data);
    res = ana.file.yaml.koch.dump(koch,options.Style);
end

% While Koch's parser does the ConvertToArray just fine,
% the opposite is not true, therefore, we convert the data.
function koch = convertStructureArrays(data)
    if isstruct(data) 
        fn = fieldnames(data);
        if isscalar(data)
            koch = data;
            for f = 1:length(fn)
                koch.(fn{f}) = convertStructureArrays(data.(fn{f}));
            end
        else
            koch = cell(length(data),1);
            for i = 1:length(data)
                koch{i} = convertStructureArrays(data(i));
            end
        end
    else
        koch = data;
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
