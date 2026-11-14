classdef testaliascollapse < matlab.unittest.TestCase
    %TESTALIASCOLLAPSE  Unit tests for ana.fs.alias.collapse.
    %
    % Expected alias representation: ana.type.dict whose entries contain
    % cell arrays of ana.fs.path objects, matching ana.session.Aliases.
    % All inputs are synthetic; no session or filesystem access needed.
    % Install in tests/fs/testaliascollapse.m.

    methods (Test)
        function unrelatedAbsolutePathIsUnchanged(testCase)
            p = ana.fs.path("/unrelated/trial.mat");
            result = ana.fs.alias.collapse(p, Aliases=testaliascollapse.aliases());

            testCase.verifyEqual(string(result), string(p));
            testCase.verifyFalse(result.isalias());
        end

        function collapsesSimpleLocation(testCase)
            p = ana.fs.path("/ana-test/project/raw/trial.mat");
            result = ana.fs.alias.collapse(p, Aliases=testaliascollapse.aliases());

            testCase.verifyEqual(string(result), "{project}/raw/trial.mat");
            testCase.verifyTrue(result.isalias());
        end

        function collapsesExactLocation(testCase)
            % No trailing path component is required for a match.
            p = ana.fs.path("/ana-test/project");
            result = ana.fs.alias.collapse(p, Aliases=testaliascollapse.aliases());

            testCase.verifyEqual(string(result), "{project}");
        end

        function doesNotMatchPartialComponent(testCase)
            p = ana.fs.path("/ana-test/project-old/data.mat");
            result = ana.fs.alias.collapse(p, Aliases=testaliascollapse.aliases());

            testCase.verifyEqual(string(result), string(p));
        end

        function doesNotMatchShorterPath(testCase)
            p = ana.fs.path("/ana-test");
            result = ana.fs.alias.collapse(p, Aliases=testaliascollapse.aliases());

            testCase.verifyEqual(string(result), string(p));
        end

        function collapsesSecondLocationOfSearchPath(testCase)
            p = ana.fs.path("/ana-test/storage-b/trial.mat");
            result = ana.fs.alias.collapse(p, Aliases=testaliascollapse.aliases());

            testCase.verifyEqual(string(result), "{storage}/trial.mat");
        end

        function collapsesNestedAlias(testCase)
            % Repeated collapse should reach the most nested alias.
            p = ana.fs.path("/ana-test/project/results/trial.mat");
            result = ana.fs.alias.collapse(p, Aliases=testaliascollapse.aliases());

            testCase.verifyEqual(string(result), "{results}/trial.mat");
        end

        function collapsedPathHasLocalCategory(testCase)
            % Alias paths are locally represented; candidate categories
            % are recovered when expanding the alias.
            p = ana.fs.path("/ana-test/storage-b/trial.mat", ...
                Category=ana.fs.category.external);
            result = ana.fs.alias.collapse(p, Aliases=testaliascollapse.aliases());

            testCase.verifyEqual(string(result), "{storage}/trial.mat");
            testCase.verifyEqual(result.Category, ana.fs.category.local);
        end

        function unmatchedPathKeepsItsCategory(testCase)
            p = ana.fs.path("/unrelated/trial.mat", ...
                Category=ana.fs.category.network);
            result = ana.fs.alias.collapse(p, Aliases=testaliascollapse.aliases());

            testCase.verifyEqual(string(result), string(p));
            testCase.verifyEqual(result.Category, ana.fs.category.network);
        end

        function collapseDoesNotModifyInput(testCase)
            p = ana.fs.path("/ana-test/project/raw.mat", ...
                Category=ana.fs.category.network);
            result = ana.fs.alias.collapse(p, Aliases=testaliascollapse.aliases());

            testCase.verifyEqual(string(p), "/ana-test/project/raw.mat");
            testCase.verifyEqual(p.Category, ana.fs.category.network);
            testCase.verifyEqual(string(result), "{project}/raw.mat");
        end

        function collapseAndExpandRoundTrip(testCase)
            a = testaliascollapse.aliases();
            original = ana.fs.path("/ana-test/project/raw/trial.mat");
            collapsed = ana.fs.alias.collapse(original, Aliases=a);
            candidates = ana.fs.alias.expand(collapsed, Aliases=a);

            testCase.assertNumElements(candidates, 1);
            testCase.verifyEqual(string(candidates{1}), string(original));
        end

        function aliasNamedLikeDictMethod(testCase)
            a = ana.type.dict();
            a.keys = {ana.fs.path("/ana-test/method-name")};
            result = ana.fs.alias.collapse( ...
                ana.fs.path("/ana-test/method-name/file"), Aliases=a);

            testCase.verifyEqual(string(result), "{keys}/file");
        end

        function acceptsStructAliasDefinitions(testCase)
            % A struct is accepted by the public Aliases type check.
            a = struct();
            a.project = {ana.fs.path("/ana-test/project")};
            a.results = {ana.fs.path("{project}/results")};
            result = ana.fs.alias.collapse( ...
                ana.fs.path("/ana-test/project/file"), Aliases=a);

            testCase.verifyEqual(string(result), "{project}/file");
        end
    end

    methods (Static, Access=private)
        function a = aliases()
            a = ana.type.dict();
            a.project = {ana.fs.path("/ana-test/project")};
            a.storage = { ...
                ana.fs.path("/ana-test/storage-a", Category=ana.fs.category.network), ...
                ana.fs.path("/ana-test/storage-b", Category=ana.fs.category.external)};
            a.results = {ana.fs.path("{project}/results")};
        end
    end
end
