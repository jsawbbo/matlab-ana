function res = readcsv(filename)
    %ana.dlc.readcsv        Read CSV-file from DLC.
    %   

    f = fopen(filename);
    assert(~isempty(f), "Could not option DLC CSV: %s", filename);

    % Read first three lines of the file and parse CSV header columns
    % Read whole first three lines as text
    lines = cell(3,1);
    for k = 1:3
        t = fgetl(f);
        if ~ischar(t)
            error('File has fewer than 3 lines: %s', filename);
        end
        lines{k} = t;
    end
    
    % Split each line by commas, preserving empty fields
    parts = cell(3,1);
    maxN = 0;
    for k = 1:3
        % Use regexp to split on commas (including empty tokens)
        parts{k} = regexp(lines{k}, ',', 'split');
        maxN = max(maxN, numel(parts{k}));
    end
    
    % Pad shorter rows with empty strings and build [3 N] string array
    cols = strings(3, maxN);
    for k = 1:3
        n = numel(parts{k});
        cols(k,1:n) = string(parts{k});
        if n < maxN
            cols(k,n+1:maxN) = "";
        end
    end
    
    % Variable names from header
    vars = cols(2,1:3:end);
    
    % Read data
    text = fread(f, '*char')';
    fclose(f);

    data = str2num(text); %#ok<ST2NM>

    % Build result struct
    res = struct();

    res.frame = data(:,1);
    for k = 2:numel(vars)-1
        idx = (k-2)*3+1;
        tmp = struct(x=data(:,idx+1),y=data(:,idx+2),likelihood=data(:,idx+3));
        res.(vars(k)) = tmp;
    end
    
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
%
% Development assistance:
%   Matlab copilot
%