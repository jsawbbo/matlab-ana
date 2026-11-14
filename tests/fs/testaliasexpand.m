classdef testaliasexpand < matlab.unittest.TestCase
    %TESTALIASEXPAND  Unit tests for ana.fs.alias.expand.
    %
    % All aliases are supplied explicitly; no session or real files needed.
    % Alias entries are cell arrays of ana.fs.path objects, as in ana.session.
    % Install in tests/fs/testaliasexpand.m.

    methods (Test)
        function ordinaryRelativePathPassesThrough(testCase)
            p = ana.fs.path("data/trial.mat");
            result = ana.fs.alias.expand(p, Aliases=testaliasexpand.aliases());

            testCase.assertClass(result, 'cell');
            testCase.assertNumElements(result, 1);
            testCase.verifyEqual(string(result{1}), "data/trial.mat");
        end

        function absolutePathPassesThrough(testCase)
            p = ana.fs.path("/unrelated/trial.mat", ...
                Category=ana.fs.category.external);
            result = ana.fs.alias.expand(p, Aliases=testaliasexpand.aliases());

            testCase.assertClass(result, 'cell');
            testCase.assertNumElements(result, 1);
            testCase.verifyEqual(string(result{1}), string(p));
            testCase.verifyEqual(result{1}.Category, ana.fs.category.external);
        end

        function expandsSimpleAlias(testCase)
            p = ana.fs.path("{project}/raw/trial.mat");
            result = ana.fs.alias.expand(p, Aliases=testaliasexpand.aliases());

            testCase.assertNumElements(result, 1);
            testCase.verifyClass(result{1}, 'ana.fs.path');
            testCase.verifyEqual(string(result{1}), "/ana-test/project/raw/trial.mat");
            testCase.verifyFalse(result{1}.isalias());
        end

        function expandsAliasWithoutSuffix(testCase)
            % Exact alias roots are valid candidates, too.
            p = ana.fs.path("{project}");
            result = ana.fs.alias.expand(p, Aliases=testaliasexpand.aliases());

            testCase.assertNumElements(result, 1);
            testCase.verifyEqual(string(result{1}), "/ana-test/project");
        end

        function expandsMultipleLocationsInOrder(testCase)
            p = ana.fs.path("{storage}/trial.mat");
            result = ana.fs.alias.expand(p, Aliases=testaliasexpand.aliases());

            testCase.assertNumElements(result, 2);
            testCase.verifyEqual(string(result{1}), "/ana-test/storage-a/trial.mat");
            testCase.verifyEqual(string(result{2}), "/ana-test/storage-b/trial.mat");
        end

        function inheritsCategoryFromLocation(testCase)
            % The candidate's category comes from the configured location,
            % not from the unresolved alias path.
            p = ana.fs.path("{storage}/trial.mat");
            result = ana.fs.alias.expand(p, Aliases=testaliasexpand.aliases());

            testCase.assertNumElements(result, 2);
            testCase.verifyEqual(result{1}.Category, ana.fs.category.network);
            testCase.verifyEqual(result{2}.Category, ana.fs.category.external);
        end

        function expandsNestedAlias(testCase)
            p = ana.fs.path("{results}/trial.mat");
            result = ana.fs.alias.expand(p, Aliases=testaliasexpand.aliases());

            testCase.assertNumElements(result, 1);
            testCase.verifyEqual(string(result{1}), ...
                "/ana-test/project/results/trial.mat");
        end

        function expandsTwoLevelsOfNesting(testCase)
            p = ana.fs.path("{processed}/trial.mat");
            result = ana.fs.alias.expand(p, Aliases=testaliasexpand.aliases());

            testCase.assertNumElements(result, 1);
            testCase.verifyEqual(string(result{1}), ...
                "/ana-test/project/results/processed/trial.mat");
        end

        function unknownAliasProducesNoCandidates(testCase)
            p = ana.fs.path("{missing}/trial.mat");
            result = ana.fs.alias.expand(p, Aliases=testaliasexpand.aliases());

            testCase.verifyClass(result, 'cell');
            testCase.verifyEmpty(result);
        end

        function emptyAliasListProducesNoCandidates(testCase)
            a = testaliasexpand.aliases();
            a.empty = {};
            result = ana.fs.alias.expand(ana.fs.path("{empty}/x"), Aliases=a);

            testCase.verifyClass(result, 'cell');
            testCase.verifyEmpty(result);
        end

        function acceptsStructAliasDefinitions(testCase)
            % The public Aliases argument advertises both structs and dicts.
            a = struct();
            a.project = {ana.fs.path("/ana-test/project")};
            result = ana.fs.alias.expand(ana.fs.path("{project}/file"), ...
                Aliases=a);

            testCase.assertNumElements(result, 1);
            testCase.verifyEqual(string(result{1}), "/ana-test/project/file");
        end

        function aliasNamedLikeDictMethod(testCase)
            a = ana.type.dict();
            a.keys = {ana.fs.path("/ana-test/method-name")};
            result = ana.fs.alias.expand(ana.fs.path("{keys}/file"), ...
                Aliases=a);

            testCase.assertNumElements(result, 1);
            testCase.verifyEqual(string(result{1}), "/ana-test/method-name/file");
        end

        function expansionDoesNotModifyInput(testCase)
            a = testaliasexpand.aliases();
            p = ana.fs.path("{storage}/trial.mat");
            result = ana.fs.alias.expand(p, Aliases=a);

            testCase.verifyEqual(string(p), "{storage}/trial.mat");
            testCase.verifyEqual(p.Category, ana.fs.category.local);
            testCase.verifyEqual(string(a.storage{1}), "/ana-test/storage-a");
            testCase.verifyEqual(result{1}.Category, ana.fs.category.network);
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
            a.processed = {ana.fs.path("{results}/processed")};
        end
    end
end
