function runtests(options)
    arguments
        options.Verbose = false         % Show suite results verbosely.
        options.FailedOnly = false      % Rerun only failed tests.
    end

    import matlab.unittest.TestSuite
    
    failures = struct('Folder', {}, 'Test', {}, 'Result', {});

    if ~options.FailedOnly       
        list = dir('tests');
        for k = 3:numel(list)
            if ~list(k).isdir
                continue
            end
        
            folder = list(k).name;
        
            fprintf("======== ana.%s:\n", folder);
            suite = TestSuite.fromFolder(fullfile('tests', folder));
        
            results = run(suite);
            if options.Verbose
                table(results)
            end
        
            % Collect failed and incomplete tests.
            idx = find([results.Failed] | [results.Incomplete]);
        
            for j = idx
                failures(end+1).Folder = string(folder);
                failures(end).Test = string(results(j).Name);
                failures(end).Result = results(j);
            end
        end
    else
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

        % Group previous failures by folder.
        folders = unique([previous.Folder]);
    
        for folder = folders
            % Get the names of failed tests in this folder.
            idx = [previous.Folder] == folder;
            names = [previous(idx).Test];
    
            fprintf("======== ana.%s:\n", folder);
    
            % Run ONLY these tests.
            suite = TestSuite.fromFolder( ...
                fullfile('tests', folder), Name=names);
    
            if isempty(suite)
                warning("No matching tests found in %s", folder);
                continue
            end
    
            results = run(suite);
    
            if options.Verbose
                table(results)
            end
    
            % Remember tests that are still failing.
            idx = find([results.Failed] | [results.Incomplete]);
    
            for j = idx
                failures(end+1).Folder = folder;
                failures(end).Test = string(results(j).Name);
                failures(end).Result = results(j);
            end
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
