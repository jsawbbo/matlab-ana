classdef testlist < matlab.unittest.TestCase
    %TESTLIST   Contract and regression tests for ana.config.node.list.
    %
    % Install as tests/config/testlist.m.
    % No files, session, GUI, or schema registry are required.
    %
    % List elements are leaf nodes; get() returns ordinary MATLAB values.
    % Tests of get()/set() round-trips for entire configuration trees
    % belong in the future ana.config.object suite.

    methods (Test)
        %% Construction and inspection
        function defaultConstructorIsEmpty(testCase)
            obj = ana.config.node.list();
            testCase.verifyClass(obj, 'ana.config.node.list');
            testCase.verifyTrue(isempty(obj));
            testCase.verifyEqual(numel(obj), 0);
            testCase.verifyEqual(length(obj), 0);
        end

        function emptyListReturnsEmptyCell(testCase)
            obj = ana.config.node.list();
            testCase.verifyEqual(obj.get(), {});
            testCase.verifyEqual(+obj, {});
        end

        function staticEmptyConstructsAList(testCase)
            obj = ana.config.node.list.empty();
            testCase.verifyClass(obj, 'ana.config.node.list');
            testCase.verifyTrue(isempty(obj));
        end

        function setCellCreatesLeafNodes(testCase)
            obj = ana.config.node.list();
            obj.set({10, 20, 30});
            testCase.verifyClass(obj(1), 'ana.config.node.leaf');
            testCase.verifyEqual(numel(obj), 3);
            testCase.verifyFalse(isempty(obj));
        end

        function getReturnsValuesNotNodes(testCase)
            obj = ana.config.node.list();
            obj.set({10, 20, 30});
            data = obj.get();
            testCase.verifyClass(data, 'cell');
            testCase.verifyEqual(data(:), {10; 20; 30});
            testCase.verifyFalse(isa(data{1}, 'ana.config.node.base'));
        end

        function plusReturnsPlainCellArray(testCase)
            obj = ana.config.node.list();
            obj.set({"a", "b"});
            out = +obj;
            testCase.verifyEqual(out(:), {"a"; "b"});
        end

        function sizeReflectsInternalStorage(testCase)
            obj = ana.config.node.list();
            obj.set({1, 2, 3});
            testCase.verifyEqual(size(obj), [1 3]);
            testCase.verifyEqual(size(obj, 2), 3);
            testCase.verifyEqual(length(obj), 3);
        end

        function cellReturnsNodesInsteadOfValues(testCase)
            obj = ana.config.node.list();
            obj.set({1, 2});
            nodes = cell(obj);
            testCase.verifyClass(nodes, 'cell');
            testCase.verifyClass(nodes{1}, 'ana.config.node.leaf');
            testCase.verifyEqual(nodes{1}.get(), 1);
            testCase.verifyTrue(nodes{1} == obj(1));
        end

        function valueReturnsUnderlyingNodeContainer(testCase)
            obj = ana.config.node.list();
            obj.set({"first"});
            nodes = obj.value();
            testCase.verifyClass(nodes, 'cell');
            testCase.verifyTrue(nodes{1} == obj(1));
        end

        %% Setting and replacing elements
        function setSingleIndexAppends(testCase)
            obj = ana.config.node.list();
            obj.set(1, 5);
            testCase.verifyEqual(obj.get(), {5});
        end

        function setMultipleIndexValuePairs(testCase)
            obj = ana.config.node.list();
            obj.set(1, 5, 2, 10, 3, 15);
            testCase.verifyEqual(testlist.dataColumn(obj), {5; 10; 15});
        end

        function setExistingIndexPreservesOtherElements(testCase)
            obj = ana.config.node.list();
            obj.set({1, 2, 3});
            obj.set(2, 99);
            testCase.verifyEqual(testlist.dataColumn(obj), {1; 99; 3});
        end

        function setCellReplacesAllPreviousElements(testCase)
            obj = ana.config.node.list();
            obj.set({1, 2, 3});
            obj.set({7, 8});
            testCase.verifyEqual(testlist.dataColumn(obj), {7; 8});
        end

        function emptyCellClearsElements(testCase)
            obj = ana.config.node.list();
            obj.set({1, 2});
            obj.set({});
            testCase.verifyTrue(isempty(obj));
            testCase.verifyEqual(obj.get(), {});
        end

        function clearEmptiesList(testCase)
            obj = ana.config.node.list();
            obj.set({1, 2});
            obj.clear();
            testCase.verifyTrue(isempty(obj));
        end

        function acceptsStringItems(testCase)
            obj = ana.config.node.list();
            obj.set({"one", "two"});
            testCase.verifyEqual(testlist.dataColumn(obj), {"one"; "two"});
        end

        function acceptsLogicalItems(testCase)
            obj = ana.config.node.list();
            obj.set({true, false});
            testCase.verifyEqual(testlist.dataColumn(obj), {true; false});
        end

        function acceptsIntegralItems(testCase)
            obj = ana.config.node.list();
            obj.set({int32(1), int64(2)});
            testCase.verifyEqual(testlist.dataColumn(obj), {int32(1); int64(2)});
        end

        function rejectsGapsWhenAppending(testCase)
            obj = ana.config.node.list();
            obj.set({1});
            testCase.verifyError(@() obj.set(3, 7), ...
                'ANA:runtime:invalidIndex');
            testCase.verifyEqual(obj.get(), {1});
        end

        function rejectsNonCellReplacement(testCase)
            obj = ana.config.node.list();
            testCase.verifyError(@() obj.set(123), ...
                'ANA:logic:invalidArgument');
        end

        function rejectsOddNumberOfSetArguments(testCase)
            obj = ana.config.node.list();
            testCase.verifyError(@() obj.set(1, 2, 3), ...
                'ANA:runtime:invalidArgument');
        end

        function rejectsUnsupportedLeafValue(testCase)
            obj = ana.config.node.list();
            testCase.verifyError(@() obj.set({@sin}), ...
                'ANA:runtime');
        end

        function schemaBackedListAcceptsElements(testCase)
            sch = struct('type', 'list');
            obj = ana.config.node.list(Scheme=sch);
            obj.set({1, 2});
            testCase.verifyEqual(testlist.dataColumn(obj), {1; 2});
        end

        %% Paren indexing, assignment, and deletion
        function scalarParenReferenceReturnsNode(testCase)
            obj = ana.config.node.list();
            obj.set({11, 22});
            item = obj(2);
            testCase.verifyClass(item, 'ana.config.node.leaf');
            testCase.verifyEqual(item.get(), 22);
        end

        function multipleParenReferenceReturnsCellOfNodes(testCase)
            obj = ana.config.node.list();
            obj.set({11, 22, 33});
            selected = obj([1 3]);
            testCase.verifyClass(selected, 'cell');
            testCase.verifyEqual(numel(selected), 2);
            testCase.verifyTrue(selected{1} == obj(1));
            testCase.verifyEqual(selected{2}.get(), 33);
        end

        function parenAssignmentReplacesElement(testCase)
            obj = ana.config.node.list();
            obj.set({1, 2, 3});
            obj(2) = 9;
            testCase.verifyEqual(testlist.dataColumn(obj), {1; 9; 3});
        end

        function parenAssignmentAppendsElement(testCase)
            obj = ana.config.node.list();
            obj.set({1, 2});
            obj(3) = 3;
            testCase.verifyEqual(testlist.dataColumn(obj), {1; 2; 3});
        end

        function multipleParenAssignmentUsesCellValues(testCase)
            obj = ana.config.node.list();
            obj.set({1, 2, 3});
            obj([1 3]) = {8, 9};
            testCase.verifyEqual(testlist.dataColumn(obj), {8; 2; 9});
        end

        function parenDeletionRemovesElementAndShifts(testCase)
            obj = ana.config.node.list();
            obj.set({1, 2, 3});
            obj(2) = [];
            testCase.verifyEqual(testlist.dataColumn(obj), {1; 3});
            testCase.verifyEqual(numel(obj), 2);
        end

        function deletingAllElementsEmptiesList(testCase)
            obj = ana.config.node.list();
            obj.set({1, 2});
            obj(:) = [];
            testCase.verifyEqual(obj.get(), {});
            testCase.verifyTrue(isempty(obj));
        end

        function childRootPointsToList(testCase)
            obj = ana.config.node.list();
            obj.set({42});
            item = obj(1);
            testCase.verifyTrue(item.root() == obj);
        end

        function editedChildIsVisibleInGet(testCase)
            obj = ana.config.node.list();
            obj.set({1, 2});
            node = obj(2);
            node.set(20);
            testCase.verifyEqual(testlist.dataColumn(obj), {1; 20});
        end
    end

    methods (Static, Access=private)
        function out = dataColumn(obj)
            out = obj.get();
            out = out(:);
        end
    end
end
