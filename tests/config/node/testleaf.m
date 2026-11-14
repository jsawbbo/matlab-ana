classdef testleaf < matlab.unittest.TestCase
    %TESTLEAF   Unit tests for ana.config.node.leaf.
    %
    % Place in tests/config/testleaf.m.
    % All schemes are in-memory structs. No YAML files, session settings,
    % filesystem state, or GUI interaction is required.
    %
    % Tests tagged REGRESSION document intended behavior that may expose
    % an existing implementation issue.

    methods (Test)
        %% Basic value handling
        function defaultConstructorIsEmpty(testCase)
            node = ana.config.node.leaf();
            testCase.verifyEmpty(node.get());
        end

        function constructorPreservesNumericValue(testCase)
            value = [1 2; 3 4];
            node = ana.config.node.leaf(value);
            testCase.verifyEqual(node.get(), value);
        end

        function constructorPreservesString(testCase)
            node = ana.config.node.leaf("hello");
            testCase.verifyEqual(node.get(), "hello");
        end

        function constructorPreservesLogical(testCase)
            node = ana.config.node.leaf(true);
            testCase.verifyEqual(node.get(), true);
        end

        function unaryPlusReturnsValue(testCase)
            node = ana.config.node.leaf(42);
            testCase.verifyEqual(+node, 42);
        end

        function constructorRejectsCellValue(testCase)
            testCase.verifyError( ...
                @() ana.config.node.leaf({1,2}), ...
                'ANA:scheme:invalidType');
        end

        function constructorRejectsUnsupportedValue(testCase)
            testCase.verifyError( ...
                @() ana.config.node.leaf(struct('a',1)), ...
                'ANA:runtime');
        end

        %% Type inference and validation
        function untypedEmptyValueAcceptsFirstNonemptyType(testCase)
            node = ana.config.node.leaf([]);
            node.set(10);
            testCase.verifyEqual(node.get(), 10);
            testCase.verifyError(@() node.set("text"), 'ANA:runtime');
        end

        function numericLeafCanStoreEmptyArray(testCase)
            node = ana.config.node.leaf(5);
            node.set([]);
            testCase.verifyEmpty(node.get());
        end

        function rejectsIncompatibleTypeWithoutChangingValue(testCase)
            node = ana.config.node.leaf(10);
            testCase.verifyError(@() node.set("text"), 'ANA:runtime');
            testCase.verifyEqual(node.get(), 10);
        end

        function logicalTypeStaysLogical(testCase)
            node = ana.config.node.leaf(true);
            node.set(false);
            testCase.verifyEqual(node.get(), false);
            testCase.verifyError(@() node.set(1), 'ANA:runtime');
        end

        function integralTypeAcceptsOtherIntegerClasses(testCase)
            node = ana.config.node.leaf(int32(1));
            node.set(int64(2));
            testCase.verifyEqual(node.get(), int64(2));
            testCase.verifyError(@() node.set(2.5), 'ANA:runtime');
        end

        function rejectsFunctionHandle(testCase)
            node = ana.config.node.leaf(1);
            testCase.verifyError(@() node.set(@sin), 'ANA:runtime');
        end

        %% Synthetic schemes (no scheme file loading)
        function schemaAcceptsNumericValue(testCase)
            sch = struct('type', 'numeric');
            node = ana.config.node.leaf(2.5, Scheme=sch);
            node.set(3.5);
            testCase.verifyEqual(node.get(), 3.5);
            testCase.verifyError(@() node.set("wrong"), 'ANA:runtime');
        end

        function numericBoundsIncludeEndpoints(testCase)
            sch = testleaf.numberScheme(0, 10);
            node = ana.config.node.leaf(0, Scheme=sch);
            node.set(10);
            testCase.verifyEqual(node.get(), 10);
        end

        function numericBoundsRejectBelowMinimum(testCase)
            sch = testleaf.numberScheme(0, 10);
            node = ana.config.node.leaf(5, Scheme=sch);
            testCase.verifyError(@() node.set(-1), 'ANA:runtime');
            testCase.verifyEqual(node.get(), 5);
        end

        function numericBoundsRejectAboveMaximum(testCase)
            sch = testleaf.numberScheme(0, 10);
            node = ana.config.node.leaf(5, Scheme=sch);
            testCase.verifyError(@() node.set(11), 'ANA:runtime');
            testCase.verifyEqual(node.get(), 5);
        end

        function numericBoundsCheckEveryArrayElement(testCase)
            sch = testleaf.numberScheme(0, 10);
            node = ana.config.node.leaf([2 4], Scheme=sch);
            testCase.verifyError(@() node.set([3 11]), 'ANA:runtime');
            testCase.verifyEqual(node.get(), [2 4]);
        end

        function categorySchemeAcceptsListedValues(testCase)
            sch = testleaf.categoryScheme();
            node = ana.config.node.leaf("local", Scheme=sch);
            node.set("network");
            testCase.verifyEqual(node.get(), "network");
        end

        function categorySchemeRejectsUnlistedValue(testCase)
            sch = testleaf.categoryScheme();
            node = ana.config.node.leaf("local", Scheme=sch);
            testCase.verifyError(@() node.set("unknown"), 'ANA:runtime');
            testCase.verifyEqual(node.get(), "local");
        end

        function pathSchemeAcceptsText(testCase)
            sch = struct('type', 'path');
            node = ana.config.node.leaf(ana.fs.path("alpha/beta"), Scheme=sch);
            node.set("gamma/delta");
            % The current contract allows text; coercion to path is not
            % assumed here because set() currently preserves the input.
            testCase.verifyEqual(node.get(), "gamma/delta");
        end

        function clearRestoresLiteralSchemaDefault(testCase)
            sch = struct('type','numeric', ...
                'meta',struct('default',7));
            node = ana.config.node.leaf(2, Scheme=sch);
            node.set(4);
            node.clear();
            testCase.verifyEqual(node.get(), 7);
        end

        function clearRestoresEvaluatedSchemaDefault(testCase)
            sch = struct('type','numeric', ...
                'meta',struct('default',struct('eval','2 + 3')));
            node = ana.config.node.leaf(1, Scheme=sch);
            node.clear();
            testCase.verifyEqual(node.get(), 5);
        end

        function schemeOnlyConstructorUsesDefault(testCase)
            sch = struct('type','numeric', ...
                'meta',struct('default',7));
            node = ana.config.node.leaf(Scheme=sch);
            testCase.verifyEqual(node.get(), 7);
        end

        function assigningAnotherLeafStoresItsValue(testCase)
            target = ana.config.node.leaf(1);
            source = ana.config.node.leaf(23);
            target.set(source);
            testCase.verifyEqual(target.get(), 23);
        end
    end

    methods (Static, Access=private)
        function sch = numberScheme(minimum, maximum)
            sch = struct('type','numeric', ...
                'meta',struct('limit', ...
                    struct('min',minimum,'max',maximum)));
        end

        function sch = categoryScheme()
            cats = struct('value', {'local','network','remote'});
            sch = struct('type','category', ...
                'meta',struct('categories',cats));
        end
    end
end
