function todo(folder)
    %ANA.TODO       Find all TODO and FIXME entries in text files.
    %
    %    ana.todo()                    % search ana toolbox folder 
    %    ana.todo(pwd)                 % search current path
    %
    % This function searches all text files recursively for FIXME 
    % and TODO entries and displays them separately:
    %
    % For FIXME:
    %   filename:
    %   [line:column] text...
    %
    % For TODO (two possible formats):
    %   filename:
    %   - text...                    (for inline TODO: "TODO text...")
    %   - item 1                     (for multi-line TODO block)
    %   - item 2
    %
    % The function excludes itself (ana/todo.m) from the search.
    % TODO only matches inside comments (%, %{, /*, etc. depending on file type).
    % FIXME matches anywhere (comments, code, function names, etc.).

    arguments
        folder (1,1) string = ''
    end

    fullPath = mfilename('fullpath');              % e.g., /path/to/toolbox/+ana/todo
    
    if isempty(folder) || (strlength(folder) == 0)
        % Determine the root directory (parent of the directory containing this file)
        [packageDir, ~, ~] = fileparts(fullPath);  % /path/to/toolbox/+ana
        [rootDir, ~, ~] = fileparts(packageDir);   % /path/to/toolbox
    
        % Check if root directory exists
        if ~isfolder(rootDir)
            error('Cannot determine toolbox root directory.');
        end
    else
        rootDir = folder;
    end

    % Exclude the todo.m file itself
    selfPath = which('ana.todo');
    if isempty(selfPath)
        selfPath = fullPath;
    end

    % Supported text file extensions (can be extended)
    textExtensions = {'.m', '.txt', '.md', '.mlx', '.json', '.xml', '.html', '.css', '.js', '.csv', '.py', '.c', '.cpp', '.h'};

    % Initialize containers for results
    fixmeEntries = {};   % each element: {filename, lineNumber, column, text}
    todoEntries = {};    % each element: {filename, lineNumber, text} or special structure for multi-line

    % Recursively search for files
    files = dir(fullfile(rootDir, '**', '*.*'));
    totalFiles = numel(files);
    if totalFiles == 0
        fprintf('No files found in %s\n', rootDir);
        return;
    end

    for k = 1:totalFiles
        filePath = fullfile(files(k).folder, files(k).name);
        if files(k).isdir
            continue;
        end
        
        % Skip the todo.m file itself
        if strcmp(filePath, selfPath)
            continue;
        end

        % Check if extension is in our list of text files
        [~, ~, ext] = fileparts(filePath);
        if ~ismember(lower(ext), textExtensions)
            continue;
        end

        % Skip binary files that may be misidentified
        if isBinaryFile(filePath)
            continue;
        end

        % Scan the file for TODO/FIXME
        try
            fid = fopen(filePath, 'r');
            if fid == -1
                continue;
            end

            % Get relative filename from toolbox root
            relPath = strrep(filePath, [char(rootDir) filesep], '');
            lineNum = 0;
            inMultilineComment = false;
            currentMultilineTodo = [];  % Structure to collect multi-line TODO items
            todoBlockStartLine = 0;
            inTodoBlock = false;        % Flag to indicate we're inside a TODO block
            
            while ~feof(fid)
                line = fgetl(fid);
                lineNum = lineNum + 1;
                if isempty(line) && ~inMultilineComment && ~inTodoBlock
                    continue;
                end
                
                % Detect multi-line comment state based on file type
                [inMultilineComment, line] = updateCommentState(line, ext, inMultilineComment);
                
                % --- Process FIXME (anywhere, any state) ---
                fixmePos = strfind(line, 'FIXME');
                if ~isempty(fixmePos)
                    for col = fixmePos
                        fixmeEntries{end+1, 1} = {relPath, lineNum, col, strtrim(line)};
                    end
                end
                
                % --- Process TODO ---
                % Check if line contains TODO in a comment (including %TODO, % TODO, //TODO, #TODO, etc.)
                [hasTodo, todoPos, cleanedLine] = hasTodoInComment(line, ext);
                
                if hasTodo
                    % Extract text after TODO
                    textAfter = extractTodoText(cleanedLine, todoPos);
                    
                    % Check if this is a standalone TODO (just "TODO" or "TODO" with nothing else)
                    if isempty(strtrim(textAfter))
                        % Start a new TODO block
                        inTodoBlock = true;
                        currentMultilineTodo = {};
                        todoBlockStartLine = lineNum;
                    else
                        % Inline TODO with content
                        todoEntries{end+1, 1} = {relPath, lineNum, textAfter, 'inline'};
                        inTodoBlock = false;  % Reset block state
                        currentMultilineTodo = {};
                    end
                elseif inTodoBlock
                    % We're inside a TODO block - look for bullet points
                    trimmedLine = strtrim(line);
                    if startsWith(trimmedLine, '%')
                        trimmedLine = strtrim(extractAfter(trimmedLine,1));
                    end
                    
                    % Check if this line starts with a bullet point (-, *, •)
                    if ~isempty(trimmedLine) && (startsWith(trimmedLine, '-') || ...
                                                  startsWith(trimmedLine, '*') || ...
                                                  startsWith(trimmedLine, '•'))
                        % Extract bullet text (remove the bullet character and space)
                        bulletText = strtrim(trimmedLine(2:end));
                        if ~isempty(bulletText)
                            currentMultilineTodo{end+1} = bulletText;
                        end
                    elseif ~isempty(trimmedLine) && ~isempty(currentMultilineTodo)
                        % Non-bullet line encountered - end of TODO block
                        if ~isempty(currentMultilineTodo)
                            todoEntries{end+1, 1} = {relPath, todoBlockStartLine, currentMultilineTodo, 'multiline'};
                        end
                        inTodoBlock = false;
                        currentMultilineTodo = {};
                    elseif isempty(trimmedLine)
                        % Empty line - keep the block alive if we have items
                        % Do nothing, just continue
                    end
                end
            end
            
            % End of file - save any pending TODO block
            if inTodoBlock && ~isempty(currentMultilineTodo)
                todoEntries{end+1, 1} = {relPath, todoBlockStartLine, currentMultilineTodo, 'multiline'};
            end
            
            fclose(fid);
        catch ME
            warning('Could not read file %s: %s', relPath, ME.message);
            if fid ~= -1, fclose(fid); end
        end
    end

    % --- Output FIXME entries first ---
    if ~isempty(fixmeEntries)
        fprintf('\n========== FIXME ==========\n\n');
        printFixmeEntries(fixmeEntries);
    else
        fprintf('\n========== FIXME ==========\n');
        fprintf('No FIXME entries found.\n');
    end

    % --- Output TODO entries next ---
    if ~isempty(todoEntries)
        fprintf('\n\n========== TODO ==========\n\n');
        printTodoEntries(todoEntries);
    else
        fprintf('\n========== TODO ==========\n');
        fprintf('No TODO entries found.\n');
    end
end

function [inComment, lineOut] = updateCommentState(line, ext, currentState)
% Update multi-line comment state based on file extension
    lineOut = line;
    inComment = currentState;
    
    switch lower(ext)
        case {'.m', '.mlx'}
            % MATLAB: check for %{ and %}
            if ~currentState && contains(line, '%{')
                inComment = true;
            elseif currentState && contains(line, '%}')
                inComment = false;
            end
        case {'.c', '.cpp', '.h', '.js', '.java'}
            % C-style: check for /* and */
            if ~currentState && contains(line, '/*')
                inComment = true;
            elseif currentState && contains(line, '*/')
                inComment = false;
            end
        case {'.py'}
            % Python uses triple quotes
            if ~currentState && contains(line, '"""')
                inComment = true;
            elseif currentState && contains(line, '"""')
                inComment = false;
            elseif ~currentState && contains(line, "'''")
                inComment = true;
            elseif currentState && contains(line, "'''")
                inComment = false;
            end
        otherwise
            % For other file types, no multi-line comment tracking
            inComment = currentState;
    end
end

function [hasTodo, todoPos, cleanedLine] = hasTodoInComment(line, ext)
% Check if line contains TODO inside a comment
% Returns:
%   hasTodo - boolean
%   todoPos - position of TODO in the cleaned line (after removing comment markers)
%   cleanedLine - line with comment markers removed
    hasTodo = false;
    todoPos = [];
    cleanedLine = line;
    
    switch lower(ext)
        case {'.m', '.mlx'}
            % MATLAB comments: % or %{
            commentPos = strfind(line, '%');
            if ~isempty(commentPos)
                % Take the last comment marker (handles % in strings, but good enough)
                lastCommentPos = commentPos(end);
                cleanedLine = strtrim(line(lastCommentPos+1:end));
                % Look for TODO (with or without space after %)
                todoIdx = strfind(cleanedLine, 'TODO');
                if ~isempty(todoIdx)
                    hasTodo = true;
                    todoPos = todoIdx(1);
                end
            end
        case {'.c', '.cpp', '.h', '.js', '.java'}
            % C-style: // 
            commentPos = strfind(line, '//');
            if ~isempty(commentPos)
                cleanedLine = strtrim(line(commentPos(1)+2:end));
                todoIdx = strfind(cleanedLine, 'TODO');
                if ~isempty(todoIdx)
                    hasTodo = true;
                    todoPos = todoIdx(1);
                end
            end
        case {'.py'}
            % Python: #
            commentPos = strfind(line, '#');
            if ~isempty(commentPos)
                cleanedLine = strtrim(line(commentPos(1)+1:end));
                todoIdx = strfind(cleanedLine, 'TODO');
                if ~isempty(todoIdx)
                    hasTodo = true;
                    todoPos = todoIdx(1);
                end
            end
        case {'.txt', '.md'}
            % Text files: everything is content
            cleanedLine = line;
            todoIdx = strfind(line, 'TODO');
            if ~isempty(todoIdx)
                hasTodo = true;
                todoPos = todoIdx(1);
            end
        otherwise
            % Assume everything is content
            cleanedLine = line;
            todoIdx = strfind(line, 'TODO');
            if ~isempty(todoIdx)
                hasTodo = true;
                todoPos = todoIdx(1);
            end
    end
end

function textOut = extractTodoText(line, todoPos)
% Extract text after TODO (including the word TODO if it's part of sentence)
    if todoPos + 4 <= length(line)
        textOut = strtrim(line(todoPos + 4:end));
        if isempty(textOut) || isequal(textOut,':')
            textOut = '';
        end
    else
        textOut = '';
    end
end

function printFixmeEntries(entries)
% Print FIXME entries grouped by filename
    if isempty(entries)
        return;
    end

    % Group by filename
    filenameMap = containers.Map();
    for i = 1:size(entries, 1)
        entry = entries{i};
        filename = entry{1};
        if isKey(filenameMap, filename)
            filenameMap(filename) = [filenameMap(filename), i];
        else
            filenameMap(filename) = i;
        end
    end

    % Output each file's entries
    allFiles = keys(filenameMap);
    for f = 1:length(allFiles)
        filename = allFiles{f};
        fprintf('%s:\n', filename);
        
        indices = filenameMap(filename);
        for j = 1:length(indices)
            idx = indices(j);
            lineNum = entries{idx}{2};
            colNum  = entries{idx}{3};
            text    = entries{idx}{4};
            % Remove leading/trailing spaces and collapse multiple spaces
            text = strtrim(regexprep(text, '\s+', ' '));
            fprintf('  [%d:%d] %s\n', lineNum, colNum, text);
        end
        fprintf('\n');
    end
end

function printTodoEntries(entries)
% Print TODO entries grouped by filename
    if isempty(entries)
        return;
    end

    % Group by filename
    filenameMap = containers.Map();
    for i = 1:size(entries, 1)
        entry = entries{i};
        filename = entry{1};
        if isKey(filenameMap, filename)
            filenameMap(filename) = [filenameMap(filename), i];
        else
            filenameMap(filename) = i;
        end
    end

    % Output each file's entries
    allFiles = keys(filenameMap);
    for f = 1:length(allFiles)
        filename = allFiles{f};
        fprintf('%s:\n', filename);
        
        indices = filenameMap(filename);
        for j = 1:length(indices)
            idx = indices(j);
            todoType = entries{idx}{4};
            
            if strcmp(todoType, 'inline')
                % Inline TODO: just show the bullet point
                text = entries{idx}{3};
                fprintf('  - %s\n', text);
            elseif strcmp(todoType, 'multiline')
                % Multi-line TODO block: show all bullet points
                items = entries{idx}{3};
                for k = 1:length(items)
                    fprintf('  - %s\n', items{k});
                end
            end
        end
        fprintf('\n');
    end
end

function isBin = isBinaryFile(filepath)
% Quick heuristic: read first 1024 bytes, if a high proportion of null bytes
% or non-printable ASCII appears, treat as binary.
    fid = fopen(filepath, 'r');
    if fid == -1
        isBin = true;
        return;
    end
    data = fread(fid, 1024, '*uint8');
    fclose(fid);
    if isempty(data)
        isBin = false;
        return;
    end
    % Count null bytes and control chars (excluding CR, LF, TAB)
    nonText = sum(data == 0) + sum(data < 9) + sum(data == 11) + sum(data == 12) + sum(data > 13 & data < 32) + sum(data == 127);
    ratio = nonText / numel(data);
    isBin = ratio > 0.10;  % if >10% binary-ish chars, treat as binary
end

% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
%
% Development assistance:
%   DeepSeek (深度求索) — todo.m function implementation 
%                        (with minor Author corrections)
