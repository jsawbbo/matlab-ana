classdef testdict < matlab.unittest.TestCase
    %TESTDICT   Contract and regression tests for ana.config.node.dict.
    %
    % Install as tests/config/testdict.m.
    % Uses synthetic in-memory schemes. No YAML files, GUI, or session.
    %
    % The apply/reset tests express the intended recursive behavior: a
    % configuration transaction must include mutations of child nodes.

    methods (Test)
        %% Construction and basic values
        function defaultConstructorIsEmpty(testCase)
            d = ana.config.node.dict();
            testCase.verifyClass(d, 'ana.config.node.dict');
            testCase.verifyEmpty(fieldnames(d));
            testCase.verifyEqual(d.get(), struct());
        end

        function setCreatesLeaf(testCase)
            d = ana.config.node.dict();
            d.set('answer', 42);
            testCase.verifyClass(d.answer, 'ana.config.node.leaf');
            testCase.verifyEqual(d.answer.get(), 42);
        end

        function dotAssignmentCreatesLeaf(testCase)
            d = ana.config.node.dict();
            d.answer = 42;
            testCase.verifyEqual(d.answer.get(), 42);
        end

        function multipleNameValuePairs(testCase)
            d = ana.config.node.dict();
            d.set('a', 12, 'b', "hello", 'c', true);
            testCase.verifyEqual(d.a.get(), 12);
            testCase.verifyEqual(d.b.get(), "hello");
            testCase.verifyEqual(d.c.get(), true);
        end

        function matlabNamedArguments(testCase)
            d = ana.config.node.dict();
            d.set(alpha=7, beta="test");
            testCase.verifyEqual(d.alpha.get(), 7);
            testCase.verifyEqual(d.beta.get(), "test");
        end

        function setReturnsSameHandle(testCase)
            d = ana.config.node.dict();
            returned = d.set('value', 1);
            testCase.verifyTrue(returned == d);
        end

        function materializesAsNativeStruct(testCase)
            d = ana.config.node.dict();
            d.set('a', 1, 'b', "text");
            result = d.get();
            testCase.verifyClass(result, 'struct');
            testCase.verifyEqual(result.a, 1);
            testCase.verifyEqual(result.b, "text");
        end

        function unaryPlusMaterializesValues(testCase)
            d = ana.config.node.dict();
            d.set('value', 19);
            result = +d;
            testCase.verifyClass(result, 'struct');
            testCase.verifyEqual(result.value, 19);
        end

        function storesEmptyValueWithoutDeletingKey(testCase)
            d = ana.config.node.dict();
            d.set('blank', []);
            testCase.verifyTrue(isfield(d, 'blank'));
            testCase.verifyClass(d.blank, 'ana.config.node.leaf');
            testCase.verifyEmpty(d.blank.get());
        end

        function updateRetainsExistingChildNode(testCase)
            d = ana.config.node.dict();
            d.set('answer', 4);
            oldNode = d.answer;
            d.answer = 5;
            testCase.verifyTrue(d.answer == oldNode);
            testCase.verifyEqual(oldNode.get(), 5);
        end

        function invalidReplacementDoesNotChangeValue(testCase)
            d = ana.config.node.dict();
            d.set('answer', 4);
            testCase.verifyError(@() d.set('answer', "not a number"), 'ANA:runtime');
            testCase.verifyEqual(d.answer.get(), 4);
        end

        function supportsSeveralLeafTypes(testCase)
            d = ana.config.node.dict();
            d.set('enabled', false, 'count', int32(3), 'label', "test");
            testCase.verifyEqual(d.enabled.get(), false);
            testCase.verifyEqual(d.count.get(), int32(3));
            testCase.verifyEqual(d.label.get(), "test");
        end

        %% Hierarchical configuration
        function structValueCreatesNestedDictionary(testCase)
            d = ana.config.node.dict();
            d.set('inner', struct('x', 1, 'y', "two"));
            testCase.verifyClass(d.inner, 'ana.config.node.dict');
            testCase.verifyEqual(d.inner.x.get(), 1);
            testCase.verifyEqual(d.inner.y.get(), "two");
        end

        function nestedDictionaryMaterializesRecursively(testCase)
            d = ana.config.node.dict();
            d.set('inner', struct('x', 11));
            out = d.get();
            testCase.verifyClass(out, 'struct');
            testCase.verifyClass(out.inner, 'struct');
            testCase.verifyEqual(out.inner.x, 11);
        end

        function nestedDotAssignmentUpdatesValue(testCase)
            d = ana.config.node.dict();
            d.set('inner', struct('x', 1));
            d.inner.x = 23;
            testCase.verifyEqual(d.inner.x.get(), 23);
        end

        function childRootIsItsContainingDictionary(testCase)
            d = ana.config.node.dict();
            d.set('inner', struct('x', 3));
            testCase.verifyTrue(d.inner.root() == d);
            testCase.verifyTrue(d.inner.x.root() == d);
        end

        function cellValueCreatesList(testCase)
            d = ana.config.node.dict();
            d.set('numbers', {2, 4, 6});
            testCase.verifyClass(d.numbers, 'ana.config.node.list');
            values = d.numbers.get();
            testCase.verifyEqual(values(:), {2; 4; 6});
        end

        function mixedTreeReturnsPlainMatlabValues(testCase)
            d = ana.config.node.dict();
            d.set('metadata', struct('name', "experiment"), 'ids', {1, 2});
            out = d.get();
            testCase.verifyClass(out, 'struct');
            testCase.verifyEqual(out.metadata.name, "experiment");
            testCase.verifyEqual(out.ids(:), {1; 2});
            testCase.verifyFalse(isa(out.metadata, 'ana.config.node.base'));
        end

        %% Replacement versus incremental updates
        function scalarStructReplacesDictionary(testCase)
            d = ana.config.node.dict();
            d.set('old', 1);
            d.set(struct('new', 2));
            testCase.verifyFalse(isfield(d, 'old'));
            testCase.verifyTrue(isfield(d, 'new'));
            testCase.verifyEqual(d.new.get(), 2);
        end

        function cellNameValueListReplacesDictionary(testCase)
            d = ana.config.node.dict();
            d.set('old', 1);
            d.set({'a', 2, 'b', "three"});
            testCase.verifyFalse(isfield(d, 'old'));
            testCase.verifyEqual(d.a.get(), 2);
            testCase.verifyEqual(d.b.get(), "three");
        end

        function emptyStructClearsDictionary(testCase)
            d = ana.config.node.dict();
            d.set('old', 1);
            d.set(struct());
            testCase.verifyEmpty(fieldnames(d));
        end

        function emptyCellClearsDictionary(testCase)
            d = ana.config.node.dict();
            d.set('old', 1);
            d.set({});
            testCase.verifyEmpty(fieldnames(d));
        end

        function individualAssignmentsPreserveOtherKeys(testCase)
            d = ana.config.node.dict();
            d.set('a', 1, 'b', 2);
            d.set('a', 3);
            testCase.verifyEqual(d.a.get(), 3);
            testCase.verifyEqual(d.b.get(), 2);
        end

        function fieldnamesIsfieldAndRmfield(testCase)
            d = ana.config.node.dict();
            d.set('left', 1, 'right', 2);
            testCase.verifyEqual(sort(string(fieldnames(d))), sort(["left"; "right"]));
            testCase.verifyTrue(isfield(d, 'left'));
            testCase.verifyFalse(isfield(d, 'missing'));
            d.rmfield('left');
            testCase.verifyFalse(isfield(d, 'left'));
            testCase.verifyEqual(d.right.get(), 2);
        end

        function removingMissingFieldDoesNothing(testCase)
            d = ana.config.node.dict();
            d.set('present', 3);
            d.rmfield('missing');
            testCase.verifyEqual(d.present.get(), 3);
        end

        function methodNamesCanAlsoBeKeys(testCase)
            d = ana.config.node.dict();
            d.set('get', 11, 'set', 22, 'clear', 33);
            testCase.verifyEqual(d.get.get(), 11);
            testCase.verifyEqual(d.set.get(), 22);
            testCase.verifyEqual(d.clear.get(), 33);
            d.set('other', 44);  % Method invocation must still work.
            testCase.verifyEqual(d.other.get(), 44);
            out = d.get();      % Likewise get(), despite a key named get.
            testCase.verifyEqual(out.get, 11);
        end

        function invalidSingleArgumentIsRejected(testCase)
            d = ana.config.node.dict();
            testCase.verifyError(@() d.set(42), 'ANA:logic:invalidArgument');
        end

        function oddNumberOfArgumentsIsRejected(testCase)
            d = ana.config.node.dict();
            testCase.verifyError(@() d.set('a', 1, 'b'), 'ANA:runtime:invalidArgument');
        end

        function unsupportedValueTypeIsRejected(testCase)
            d = ana.config.node.dict();
            testCase.verifyError(@() d.set('bad', containers.Map()), 'ANA:runtime:invalidType');
            testCase.verifyFalse(isfield(d, 'bad'));
        end

        function clearRemovesUnschemedFields(testCase)
            d = ana.config.node.dict();
            d.set('a', 1);
            d.clear();
            testCase.verifyEmpty(fieldnames(d));
        end

        %% Scheme-driven dictionaries
        function schemeCreatesCorrectChildNodeTypes(testCase)
            d = ana.config.node.dict(Scheme=testdict.exampleScheme());
            testCase.verifyClass(d.answer, 'ana.config.node.leaf');
            testCase.verifyClass(d.label, 'ana.config.node.leaf');
            testCase.verifyClass(d.inner, 'ana.config.node.dict');
            testCase.verifyClass(d.items, 'ana.config.node.list');
            testCase.verifyClass(d.rows, 'ana.config.node.table');
            testCase.verifyClass(d.inner.flag, 'ana.config.node.leaf');
        end

        function schemePopulatesDefaultValues(testCase)
            d = ana.config.node.dict(Scheme=testdict.exampleScheme());
            testCase.verifyEqual(d.answer.get(), 10);
            testCase.verifyEqual(d.label.get(), "default");
            testCase.verifyEqual(d.inner.flag.get(), true);
        end

        function schemeRejectsUnknownKeys(testCase)
            d = ana.config.node.dict(Scheme=testdict.exampleScheme());
            testCase.verifyError(@() d.set('unknown', 99), 'ANA:runtime:validationFailed');
            testCase.verifyFalse(isfield(d, 'unknown'));
        end

        function schemeAcceptsValidAssignment(testCase)
            d = ana.config.node.dict(Scheme=testdict.exampleScheme());
            d.set('answer', 75);
            testCase.verifyEqual(d.answer.get(), 75);
        end

        function schemaRejectsWrongValueWithoutDestroyingDefault(testCase)
            d = ana.config.node.dict(Scheme=testdict.exampleScheme());
            testCase.verifyError(@() d.set('answer', "bad"), 'ANA:runtime');
            testCase.verifyEqual(d.answer.get(), 10);
        end

        function structReplacementRestoresMissingSchemaDefaults(testCase)
            d = ana.config.node.dict(Scheme=testdict.exampleScheme());
            d.set('answer', 80, 'label', "custom");
            d.set(struct('answer', 20));
            testCase.verifyEqual(d.answer.get(), 20);
            testCase.verifyEqual(d.label.get(), "default");
            testCase.verifyTrue(isfield(d, 'inner'));
        end

        function clearRestoresSchemeDefaults(testCase)
            d = ana.config.node.dict(Scheme=testdict.exampleScheme());
            d.set('answer', 23);
            d.clear();
            testCase.verifyEqual(d.answer.get(), 10);
            testCase.verifyEqual(d.label.get(), "default");
        end
    end

    methods (Static, Access=private)
        function doc = exampleScheme()
            % Minimal hierarchy with leaves, dictionary, list, and table.
            numericLeaf = struct( ...
                'key', 'answer', ...
                'type', 'numeric', ...
                'meta', struct('default', 10));
            textLeaf = struct( ...
                'key', 'label', ...
                'type', 'string', ...
                'meta', struct('default', "default"));
            flagLeaf = struct( ...
                'key', 'flag', ...
                'type', 'logical', ...
                'meta', struct('default', true));
            innerDict = struct( ...
                'key', 'inner', ...
                'type', 'dict', ...
                'content', {{flagLeaf}});
            itemsList = struct('key', 'items', 'type', 'list');
            rowsTable = struct('key', 'rows', 'type', 'table', ...
                'content', {{struct('key', 'index', 'type', 'numeric')}});
            doc = struct('key', 'root', 'type', 'dict', ...
                'content', {{numericLeaf, textLeaf, innerDict, itemsList, rowsTable}});
        end
    end
end
