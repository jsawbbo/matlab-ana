classdef testobject < matlab.unittest.TestCase
    %TESTOBJECT  In-memory get()/set() round trips for ana.config.object.
    %
    % Install as tests/config/testobject.m.
    % No real configuration files, session state, aliases or GUI.
    % A value snapshot is expected to survive set(get()), including nested
    % dictionaries, tables, lists, and leaves. The tree is schema-backed.
    %
    % NOTE: These tests intentionally do not assert that existing child
    % *handles* survive set(struct). Currently dict.set(struct) calls
    % initialize(), which replaces them. This is a distinct contract.

    methods (Test)
        function emptySchemedObjectRoundTrip(testCase)
            obj = ana.config.object(Scheme=testobject.exampleScheme());
            before = obj.get();
            obj.set(before);
            testCase.verifyEqual(obj.get(), before);
        end

        function populatedObjectRoundTrip(testCase)
            obj = testobject.populatedObject();
            before = obj.get();
            obj.set(before);
            testCase.verifyEqual(obj.get(), before);
        end

        function restoringSnapshotUndoesNestedChanges(testCase)
            obj = testobject.populatedObject();
            before = obj.get();

            obj.set('title', "changed", 'gain', 7);
            obj.set('details', struct('mode', "other", 'count', int64(99)));
            obj.set('numbers', {7, 8, 9});
            obj.set('misc', {false, "different"});
            obj.set('rows', {struct('name', "replacement", 'score', 9)});

            testCase.verifyNotEqual(obj.get(), before);
            obj.set(before);
            testCase.verifyEqual(obj.get(), before);
        end

        function clearingAndRestoringSnapshot(testCase)
            obj = testobject.populatedObject();
            before = obj.get();
            obj.clear();
            obj.set(before);
            testCase.verifyEqual(obj.get(), before);
        end

        function aSnapshotCanPopulateAnotherObject(testCase)
            first = testobject.populatedObject();
            snapshot = first.get();
            second = ana.config.object(Scheme=testobject.exampleScheme());
            second.set(snapshot);
            testCase.verifyEqual(second.get(), snapshot);
        end

        function repeatedRoundTripsAreIdempotent(testCase)
            obj = testobject.populatedObject();
            snapshot = obj.get();
            for k = 1:3
                obj.set(obj.get());
                testCase.verifyEqual(obj.get(), snapshot);
            end
        end

        function getReturnsDetachedPlainValues(testCase)
            obj = testobject.populatedObject();
            snapshot = obj.get();
            testCase.verifyClass(snapshot, 'struct');
            testCase.verifyClass(snapshot.details, 'struct');
            testCase.verifyClass(snapshot.rows, 'cell');
            testCase.verifyClass(snapshot.rows{1}, 'struct');
            testCase.verifyClass(snapshot.numbers, 'cell');
            testCase.verifyFalse(isa(snapshot.title, 'ana.config.node.base'));

            obj.set('title', "later");
            obj.set('details', struct('mode', "later", 'count', int64(21)));
            testCase.verifyEqual(snapshot.title, "experiment");
            testCase.verifyEqual(snapshot.details.mode, "manual");
            testCase.verifyEqual(snapshot.details.count, int64(3));
        end

        function numericMatrixRemainsOneLeaf(testCase)
            obj = testobject.populatedObject();
            before = obj.get();
            testCase.verifyClass(obj.matrix, 'ana.config.node.leaf');
            testCase.verifyEqual(before.matrix, [1 2; 3 4]);
            obj.set(before);
            testCase.verifyEqual(obj.matrix.get(), [1 2; 3 4]);
            testCase.verifyClass(obj.matrix, 'ana.config.node.leaf');
        end

        function heterogeneousListRemainsHeterogeneous(testCase)
            obj = testobject.populatedObject();
            expected = obj.get();
            testCase.verifyEqual(expected.misc, {"label"; true; [1 0; 0 1]});
            obj.set(expected);
            actual = obj.get();
            testCase.verifyEqual(actual.misc, expected.misc);
        end

        function typedListElementsKeepTheirSchema(testCase)
            obj = testobject.populatedObject();
            obj.set(obj.get());
            testCase.verifyError(@() obj.numbers.set({1, "wrong"}), 'ANA:runtime');
            % A failed *whole-list* replacement may already have modified
            % the list. Atomic replacement is a separate TODO.
        end

        function emptyListsAndTablesRoundTrip(testCase)
            obj = testobject.populatedObject();
            data = obj.get();
            data.numbers = {};
            data.misc = {};
            data.rows = {};
            obj.set(data);
            snapshot = obj.get();
            obj.set(snapshot);
            testCase.verifyEqual(obj.get(), snapshot);
            testCase.verifyEqual(obj.numbers.get(), {});
            testCase.verifyEqual(obj.misc.get(), {});
            testCase.verifyEqual(obj.rows.get(), {});
        end

        function schemaConstraintsStillApplyAfterRoundTrip(testCase)
            obj = testobject.populatedObject();
            obj.set(obj.get());
            testCase.verifyError(@() obj.set('gain', 11), 'ANA:runtime');
            testCase.verifyEqual(obj.gain.get(), 2.5);
            testCase.verifyError(@() obj.set('title', 123), 'ANA:runtime');
            testCase.verifyEqual(obj.title.get(), "experiment");
        end

        function unschemedObjectStillRoundTrips(testCase)
            obj = ana.config.object();
            value = struct();
            value.title = "untyped";
            value.details = struct('count', 3);
            value.items = {"word", false, [1 2; 3 4]};
            obj.set(value);
            snapshot = obj.get();
            obj.set(snapshot);
            testCase.verifyEqual(obj.get(), snapshot);
        end

        function missingPathDefaultRoundTrips(testCase)
            % REGRESSION: A schema-defined path leaf with no default has
            % [] from get(). A round trip must be able to restore it.
            sch = struct('key', 'root', 'type', 'dict', ...
                'content', {{struct('key', 'folder', 'type', 'path')}});
            obj = ana.config.object(Scheme=sch);
            snapshot = obj.get();
            obj.set(snapshot);
            testCase.verifyEqual(obj.get(), snapshot);
        end

        function missingCategoryDefaultRoundTrips(testCase)
            % REGRESSION: Similar empty-value issue for category leaves.
            choices = struct('value', {'local', 'network'});
            choiceMeta = struct('rules', {choices});
            choice = struct('key', 'kind', 'type', 'category', ...
                'meta', choiceMeta);
            sch = struct('key', 'root', 'type', 'dict', ...
                'content', {{choice}});
            obj = ana.config.object(Scheme=sch);
            snapshot = obj.get();
            obj.set(snapshot);
            testCase.verifyEqual(obj.get(), snapshot);
        end
    end

    methods (Static, Access=private)
        function obj = populatedObject()
            obj = ana.config.object(Scheme=testobject.exampleScheme());
            obj.set(testobject.populatedValues());
        end

        function data = populatedValues()
            data = struct();
            data.title = "experiment";
            data.gain = 2.5;
            data.matrix = [1 2; 3 4];
            data.enabled = false;
            data.details = struct('mode', "manual", 'count', int64(3));
            data.numbers = {1, 2.5, 3};
            data.misc = {"label", true, [1 0; 0 1]};
            data.rows = { ...
                struct('name', "one", 'score', 1), ...
                struct('name', "two", 'score', 2.5) ...
            };
        end

        function sch = exampleScheme()
            title = struct('key', 'title', 'type', 'string', ...
                'meta', struct('default', "untitled"));
            gain = struct('key', 'gain', 'type', 'numeric', ...
                'meta', struct('default', 1, 'rules', ...
                    struct('limits', struct('min', 0, 'max', 10))));
            matrix = struct('key', 'matrix', 'type', 'numeric');
            enabled = struct('key', 'enabled', 'type', 'logical', ...
                'meta', struct('default', true));
            details = struct('key', 'details', 'type', 'dict', ...
                'content', {{ ...
                    struct('key', 'mode', 'type', 'string'), ...
                    struct('key', 'count', 'type', 'integral') ...
                }});
            numbers = struct('key', 'numbers', 'type', 'list', ...
                'content', struct('type', 'numeric'));
            misc = struct('key', 'misc', 'type', 'list');
            rows = struct('key', 'rows', 'type', 'table', ...
                'content', {{ ...
                    struct('key', 'name', 'type', 'string'), ...
                    struct('key', 'score', 'type', 'numeric') ...
                }});
            sch = struct('key', 'root', 'type', 'dict', 'version', '1.0', ...
                'content', {{title, gain, matrix, enabled, ...
                             details, numbers, misc, rows}});
        end
    end
end
