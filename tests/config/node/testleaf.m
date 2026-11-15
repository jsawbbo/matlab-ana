classdef testleaf < matlab.unittest.TestCase
    %TESTLEAF   Unit tests for ana.config.node.leaf.
    %
    % Place in tests/config/node/testleaf.m.
    % All schemes are in-memory structs. No YAML files, session settings,
    % filesystem state, or GUI interaction is required.
    %
    % Without a scheme, supported leaf value types may change freely.
    % A concrete scheme type constrains subsequent assignments.

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

        %% Modification tracking
        function clearWithoutSchemeEmptiesValue(testCase)
            node = ana.config.node.leaf(15);
            node.clear();
            testCase.verifyEmpty(node.get());
        end

        %% Dynamic leaf values and validation
        function untypedEmptyValueRemainsDynamic(testCase)
            node = ana.config.node.leaf([]);
            node.set(10);
            testCase.verifyEqual(node.get(), 10);
            node.set("text");
            testCase.verifyEqual(node.get(), "text");
            node.set(true);
            testCase.verifyEqual(node.get(), true);
        end

        function numericLeafCanStoreEmptyArray(testCase)
            node = ana.config.node.leaf(5);
            node.set([]);
            testCase.verifyEmpty(node.get());
        end

        function untypedLeafAcceptsDifferentValueTypes(testCase)
            node = ana.config.node.leaf(10);
            node.set("text");
            testCase.verifyEqual(node.get(), "text");
            node.set(eye(2));
            testCase.verifyEqual(node.get(), eye(2));
        end

        function untypedLogicalLeafCanBecomeNumeric(testCase)
            node = ana.config.node.leaf(true);
            node.set(false);
            testCase.verifyEqual(node.get(), false);
            node.set(1);
            testCase.verifyEqual(node.get(), 1);
        end

        function untypedIntegralLeafCanBecomeFloatingPoint(testCase)
            node = ana.config.node.leaf(int32(1));
            node.set(int64(2));
            testCase.verifyEqual(node.get(), int64(2));
            node.set(2.5);
            testCase.verifyEqual(node.get(), 2.5);
        end

        function rejectsFunctionHandle(testCase)
            node = ana.config.node.leaf(1);
            testCase.verifyError(@() node.set(@sin), 'ANA:runtime');
        end

        %% Synthetic schemes (no scheme file loading)
        function unsupportedTypeDoesNotChangeUntypedValue(testCase)
            node = ana.config.node.leaf("original");
            testCase.verifyError(@() node.set(@sin), 'ANA:runtime');
            testCase.verifyEqual(node.get(), "original");
        end

        function explicitWildcardSchemeAllowsTypeChanges(testCase)
            node = ana.config.node.leaf(1, Scheme=struct('type','*'));
            node.set("text");
            testCase.verifyEqual(node.get(), "text");
            node.set(false);
            testCase.verifyEqual(node.get(), false);
        end

        %% Declared types remain static

        function schemaAcceptsNumericValue(testCase)
            sch = struct('type', 'numeric');
            node = ana.config.node.leaf(2.5, Scheme=sch);
            node.set(3.5);
            testCase.verifyEqual(node.get(), 3.5);
            testCase.verifyError(@() node.set("wrong"), 'ANA:runtime');
        end

        function declaredNumericTypeRejectsChangeAndRetainsValue(testCase)
            node = ana.config.node.leaf(3, Scheme=struct('type','numeric'));
            testCase.verifyError(@() node.set("text"), 'ANA:runtime');
            testCase.verifyEqual(node.get(), 3);
        end

        function declaredLogicalTypeRejectsNumeric(testCase)
            node = ana.config.node.leaf(true, Scheme=struct('type','logical'));
            node.set(false);
            testCase.verifyError(@() node.set(1), 'ANA:runtime');
            testCase.verifyEqual(node.get(), false);
        end

        function declaredIntegralTypeAcceptsIntegerClassesOnly(testCase)
            node = ana.config.node.leaf(int32(1), Scheme=struct('type','integral'));
            node.set(int64(2));
            testCase.verifyEqual(node.get(), int64(2));
            testCase.verifyError(@() node.set(2.5), 'ANA:runtime');
            testCase.verifyEqual(node.get(), int64(2));
        end

        function declaredTypeRemainsAfterAssigningEmpty(testCase)
            node = ana.config.node.leaf(5, Scheme=struct('type','numeric'));
            node.set([]);
            testCase.verifyEmpty(node.get());
            testCase.verifyError(@() node.set("wrong"), 'ANA:runtime');
            node.set(8);
            testCase.verifyEqual(node.get(), 8);
        end

        function constructorRejectsValueOutsideDeclaredType(testCase)
            testCase.verifyError(@() ana.config.node.leaf("text", ...
                Scheme=struct('type','numeric')), 'ANA:runtime');
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
            % REGRESSION: a single out-of-range element must be rejected.
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
            % REGRESSION: a scheme-only leaf should honor its default.
            % The current leaf constructor may instead reject its implicit
            % default positional value ({}). Decide whether this is the
            % intended constructor contract if the test fails.
            sch = struct('type','numeric', ...
                'meta',struct('default',7));
            node = ana.config.node.leaf(Scheme=sch);
            testCase.verifyEqual(node.get(), 7);
        end

        function assigningAnotherLeafStoresItsValue(testCase)
            % REGRESSION: validation unwraps a leaf, but set() currently
            % appears to store the handle itself rather than its value.
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
