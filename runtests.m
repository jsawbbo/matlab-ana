function runtests(options)
    arguments
        options.Verbose = false         % Show suite results verbosely.
        options.Directories = []        % Directories to run.
        options.FailedOnly = false      % Rerun only failed tests.
    end

    import matlab.unittest.TestSuite
    
    failures = struct('Folder', {}, 'Test', {}, 'Result', {});
    previous = [];
    folders = [];

    % directories 
    if ~isempty(options.Directories)
        folders = string(options.Directories);

        for k = 1:numel(folders)
            p = ana.fs.path(folders(k));
            if ~p.isfolder()
                folders(k) = string("tests"/p);
            end
        end
    elseif options.FailedOnly
        if ~isfile('tests/failed.mat')
            fprintf("No previous failures file found, re-run without 'FailedOnly' option.\n");
            return
        end

        data = load('tests/failed.mat', 'failures');
        previous = data.failures;

        if isempty(previous)
            fprintf("No previous failures found, possibly re-run without 'FailedOnly' option.\n");
            return
        end

        folders = unique([previous.Folder]);
    else
        folders = findtests("tests",string([]));
    end

    for k = 1:numel(folders)
        folder = folders(k);

        fprintf("======== %s:\n", folder);

        % execute suite
        if ~isempty(previous)
            idx = [previous.Folder] == folder;
            names = [previous(idx).Test];
            suite = TestSuite.fromFolder(folder, Name=names);
        else
            suite = TestSuite.fromFolder(folder);
        end

        if isempty(suite)
            warning("No matching tests found in %s", folder);
            continue
        end

        results = run(suite);

        if options.Verbose
            table(results)
        end

        % remember failing tests
        idx = find([results.Failed] | [results.Incomplete]);
    
        for j = idx
            failures(end+1).Folder = folder;
            failures(end).Test = string(results(j).Name);
            failures(end).Result = results(j);
        end
    end

    % Final summary
    fprintf("\n======== FAILURE SUMMARY ========\n");

    if isempty(failures)
        fprintf("All tests passed.\n");
    else
        disp(struct2table(rmfield(failures, 'Result')));
    end

    % Preserve the complete failure information.
    save('tests/failed.mat', 'failures');
end

function folders = findtests(path, folders)
    list = dir(path);
    for k = 1:numel(list)
        if list(k).isdir
            switch(list(k).name)
                case {'.','..'}
                otherwise
                    nextpath = path + "/" + string(list(k).name);
                    folders = findtests(nextpath, folders);
                    folders = [nextpath; folders(:)];
            end
        end
    end
end