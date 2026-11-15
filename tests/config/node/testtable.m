classdef testtable < matlab.unittest.TestCase
    %TESTTABLE   Contract and regression tests for ana.config.node.table.
    %
    % Install as tests/config/node/testtable.m.
    % Uses only in-memory data and schemes; no YAML files or session state.
    %
    % A table is an ordered collection of ana.config.node.dict rows, not
    % a MATLAB built-in table. get() returns a cell array of plain records.
    % Higher-level config-object get()/set() round-trips are tested later.

    methods (Test)
        %% Construction, shape, and materialization
        function defaultConstructorIsEmpty(testCase)
            obj = ana.config.node.table();
            testCase.verifyClass(obj, 'ana.config.node.table');
            testCase.verifyTrue(isempty(obj));
            testCase.verifyEqual(numel(obj), 0);
            testCase.verifyEqual(length(obj), 0);
        end

        function emptyTableReturnsEmptyCell(testCase)
            obj = ana.config.node.table();
            testCase.verifyEqual(obj.get(), {});
            testCase.verifyEqual(+obj, {});
        end

        function staticEmptyReturnsTable(testCase)
            obj = ana.config.node.table.empty();
            testCase.verifyClass(obj, 'ana.config.node.table');
            testCase.verifyTrue(isempty(obj));
        end

        function setScalarStructCreatesDictionaryRow(testCase)
            obj = ana.config.node.table();
            obj.set(struct('name', "alpha", 'count', 2));
            testCase.verifyClass(obj(1), 'ana.config.node.dict');
            row = obj(1);
            testCase.verifyEqual(row.name.get(), "alpha");
            testCase.verifyEqual(row.count.get(), 2);
        end

        function getMaterializesRowAsPlainStruct(testCase)
            obj = ana.config.node.table();
            obj.set(struct('name', "alpha", 'count', 2));
            out = obj.get();
            testCase.verifyClass(out, 'cell');
            testCase.verifyEqual(numel(out), 1);
            testCase.verifyClass(out{1}, 'struct');
            testCase.verifyEqual(out{1}.name, "alpha");
            testCase.verifyEqual(out{1}.count, 2);
        end

        function setStructArrayCreatesMultipleRows(testCase)
            obj = ana.config.node.table();
            rows = [struct('name',"a",'count',1), ...
                    struct('name',"b",'count',2)];
            obj.set(rows);
            testCase.verifyEqual(numel(obj), 2);
            out = obj.get();
            testCase.verifyEqual(out{1}.name, "a");
            testCase.verifyEqual(out{2}.count, 2);
        end

        function setCellOfStructsCreatesMultipleRows(testCase)
            obj = ana.config.node.table();
            obj.set({struct('name',"a"), struct('name',"b")});
            testCase.verifyEqual(numel(obj), 2);
            testCase.verifyEqual(testtable.field(obj, 1, 'name'), "a");
            testCase.verifyEqual(testtable.field(obj, 2, 'name'), "b");
        end

        function setCellOfNameValueCells(testCase)
            obj = ana.config.node.table();
            obj.set({{'name', "a", 'count', 1}, ...
                     {'name', "b", 'count', 2}});
            out = obj.get();
            testCase.verifyEqual(out{1}.name, "a");
            testCase.verifyEqual(out{2}.count, 2);
        end

        function plusReturnsPlainRows(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 7));
            out = +obj;
            testCase.verifyClass(out, 'cell');
            testCase.verifyEqual(out{1}.x, 7);
        end

        function sizeAndLengthReflectRows(testCase)
            obj = ana.config.node.table();
            obj.set({struct('x',1), struct('x',2), struct('x',3)});
            testCase.verifyEqual(size(obj), [1 3]);
            testCase.verifyEqual(size(obj, 2), 3);
            testCase.verifyEqual(length(obj), 3);
        end

        function cellReturnsDictionaryNodes(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 3));
            nodes = cell(obj);
            testCase.verifyClass(nodes, 'cell');
            testCase.verifyClass(nodes{1}, 'ana.config.node.dict');
            testCase.verifyTrue(nodes{1} == obj(1));
        end

        function valueReturnsNodeContainer(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 3));
            nodes = obj.value();
            testCase.verifyClass(nodes, 'cell');
            testCase.verifyClass(nodes{1}, 'ana.config.node.dict');
            testCase.verifyTrue(nodes{1} == obj(1));
        end

        %% Whole-table replacement and editing
        function replacingRowsRemovesPreviousRows(testCase)
            obj = ana.config.node.table();
            obj.set({struct('x',1), struct('x',2)});
            obj.set(struct('y', 9));
            testCase.verifyEqual(numel(obj), 1);
            testCase.verifyEqual(testtable.field(obj, 1, 'y'), 9);
        end

        function setEmptyCellClearsTable(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 1));
            obj.set({});
            testCase.verifyTrue(isempty(obj));
            testCase.verifyEqual(obj.get(), {});
        end

        function setEmptyArrayClearsTable(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 1));
            obj.set([]);
            testCase.verifyTrue(isempty(obj));
        end

        function clearEmptiesTable(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 1));
            obj.clear();
            testCase.verifyTrue(isempty(obj));
        end

        function setExistingRowReplacesItsContents(testCase)
            obj = ana.config.node.table();
            obj.set({struct('x',1), struct('x',2)});
            obj.set(1, struct('y', 8));
            out = obj.get();
            testCase.verifyEqual(numel(out), 2);
            testCase.verifyEqual(out{1}, struct('y', 8));
            testCase.verifyEqual(out{2}, struct('x', 2));
        end

        % TODO: Decide whether set(index, name/value cell) may introduce
        % new fields in an unschemed table row (and whether other rows change).

        function setAtNextIndexAppendsRow(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 1));
            obj.set(2, struct('x', 2));
            testCase.verifyEqual(numel(obj), 2);
            testCase.verifyEqual(testtable.field(obj, 2, 'x'), 2);
        end

        function setRejectsGapsWhenAppending(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 1));
            testCase.verifyError(@() obj.set(3, struct('x', 3)), ...
                'ANA:runtime:invalidIndex');
        end

        function setRejectsNonRecordValue(testCase)
            obj = ana.config.node.table();
            testCase.verifyError(@() obj.set(42), ...
                'ANA:logic:invalidArgument');
        end

        function setRejectsOddArgumentCount(testCase)
            obj = ana.config.node.table();
            testCase.verifyError(@() obj.set(1, struct('x',1), 2), ...
                'ANA:runtime:invalidArgument');
        end

        function rejectsNonRecordInCellReplacement(testCase)
            obj = ana.config.node.table();
            testCase.verifyError(@() obj.set({42}), ...
                'ANA:logic:invalidArgument');
        end

        %% Paren indexing, assignment, and deletion
        function scalarParenReferenceReturnsRowNode(testCase)
            obj = ana.config.node.table();
            obj.set({struct('x',1), struct('x',2)});
            row = obj(2);
            testCase.verifyClass(row, 'ana.config.node.dict');
            testCase.verifyEqual(row.x.get(), 2);
        end

        function multipleParenReferenceReturnsCellOfRows(testCase)
            obj = ana.config.node.table();
            obj.set({struct('x',1), struct('x',2), struct('x',3)});
            selected = obj([1 3]);
            testCase.verifyClass(selected, 'cell');
            testCase.verifyEqual(numel(selected), 2);
            testCase.verifyTrue(selected{1} == obj(1));
            testCase.verifyEqual(selected{2}.x.get(), 3);
        end

        function parenAssignmentReplacesRow(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 1));
            obj(1) = struct('x', 99);
            testCase.verifyEqual(testtable.field(obj, 1, 'x'), 99);
        end

        function parenAssignmentAppendsRow(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 1));
            obj(2) = struct('x', 2);
            testCase.verifyEqual(testtable.field(obj, 2, 'x'), 2);
        end

        function multipleParenAssignmentWithCellValues(testCase)
            obj = ana.config.node.table();
            obj.set({struct('x',1), struct('x',2)});
            obj([1 2]) = {struct('x',8), struct('x',9)};
            testCase.verifyEqual(testtable.field(obj, 1, 'x'), 8);
            testCase.verifyEqual(testtable.field(obj, 2, 'x'), 9);
        end

        function indexedFieldAssignmentUpdatesRow(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 1));
            obj(1).x = 12;
            testCase.verifyEqual(testtable.field(obj, 1, 'x'), 12);
        end

        function indexedFieldAssignmentCreatesRow(testCase)
            obj = ana.config.node.table();
            obj(1).x = 12;
            testCase.verifyEqual(testtable.field(obj, 1, 'x'), 12);
        end

        function parenDeletionRemovesRowAndShifts(testCase)
            obj = ana.config.node.table();
            obj.set({struct('x',1), struct('x',2), struct('x',3)});
            obj(2) = [];
            testCase.verifyEqual(testtable.field(obj, 1, 'x'), 1);
            testCase.verifyEqual(testtable.field(obj, 2, 'x'), 3);
        end

        function deletingAllRowsEmptiesTable(testCase)
            obj = ana.config.node.table();
            obj.set({struct('x',1), struct('x',2)});
            obj(:) = [];
            testCase.verifyTrue(isempty(obj));
            testCase.verifyEqual(obj.get(), {});
        end

        function rowAndLeafRootPointToTable(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 4));
            row = obj(1);
            testCase.verifyTrue(row.root() == obj);
            item = row.x;
            testCase.verifyTrue(item.root() == obj);
        end

        function modifyingRowNodeAffectsTableValues(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 4));
            row = obj(1);
            row.set('x', 25);
            testCase.verifyEqual(testtable.field(obj, 1, 'x'), 25);
        end

        %% Schema-backed rows (in-memory synthetic schema)
        function unschemedTableRowAllowsLeafTypeChange(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 2));
            row = obj(1);
            row.x = "text";
            testCase.verifyEqual(testtable.field(obj, 1, 'x'), "text");
            row.x = false;
            testCase.verifyEqual(testtable.field(obj, 1, 'x'), false);
        end

        function unsupportedTableLeafUpdatePreservesValue(testCase)
            obj = ana.config.node.table();
            obj.set(struct('x', 2));
            row = obj(1);
            testCase.verifyError(@() row.set('x', @sin), 'ANA:runtime');
            testCase.verifyEqual(testtable.field(obj, 1, 'x'), 2);
        end

        function schemeCreatesCorrectLeafTypes(testCase)
            obj = ana.config.node.table(Scheme=testtable.rowScheme());
            obj.set(struct('name', "alpha", 'count', 2));
            row = obj(1);
            testCase.verifyClass(row.name, 'ana.config.node.leaf');
            testCase.verifyClass(row.count, 'ana.config.node.leaf');
            testCase.verifyEqual(testtable.field(obj, 1, 'name'), "alpha");
            testCase.verifyEqual(testtable.field(obj, 1, 'count'), 2);
        end

        function schemeRejectsUnknownField(testCase)
            obj = ana.config.node.table(Scheme=testtable.rowScheme());
            testCase.verifyError(@() obj.set(struct('alien', 1)), ...
                'ANA:runtime:validationFailed');
        end

        function schemeRejectsIncompatibleFieldType(testCase)
            obj = ana.config.node.table(Scheme=testtable.rowScheme());
            testCase.verifyError(@() obj.set(struct('name', 123, 'count', 2)), ...
                'ANA:runtime');
        end

        function schemeRejectsExistingFieldTypeChange(testCase)
            obj = ana.config.node.table(Scheme=testtable.rowScheme());
            obj.set(struct('name', "alpha", 'count', 2));
            row = obj(1);
            testCase.verifyError(@() row.set('count', "bad"), 'ANA:runtime');
            testCase.verifyEqual(testtable.field(obj, 1, 'count'), 2);
        end

        function schemeRejectsUnknownFieldOnRowEdit(testCase)
            obj = ana.config.node.table(Scheme=testtable.rowScheme());
            obj.set(struct('name', "alpha", 'count', 2));
            row = obj(1);
            testCase.verifyError(@() row.set('other', 1), ...
                'ANA:runtime:validationFailed');
            testCase.verifyEqual(row.name.get(), "alpha");
        end
    end

    methods (Static, Access=private)
        function out = row(obj, index)
            rows = obj.get();
            out = rows{index};
        end

        function out = field(obj, index, name)
            record = testtable.row(obj, index);
            out = record.(name);
        end

        function s = rowScheme()
            % Synthetic table scheme; never loads general.yml.
            s = struct('type', 'table', 'content', {{ ...
                struct('key', 'name',  'type', 'string'), ...
                struct('key', 'count', 'type', 'numeric') }});
        end
    end
end
