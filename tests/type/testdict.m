classdef testdict < matlab.unittest.TestCase
    % Unit tests for ana.type.dict.
    %
    % Put this file in tests/type/dict.m to match the existing test runner.
    % The method-name collision tests deliberately distinguish:
    %   d.keys         -> value stored under "keys"
    %   d("keys")      -> value stored under "keys"
    %   d.keys()       -> call the keys() method
    %   keys(d)        -> call the keys() method
    %

    methods (Test)
        function emptyConstructor(testCase)
            d = ana.type.dict();

            testCase.verifyEmpty(keys(d));
            testCase.verifyEmpty(fieldnames(d));
            testCase.verifyFalse(isKey(d, "missing"));
            testCase.verifyFalse(isfield(d, "missing"));
        end

        function dotAndParenAccess(testCase)
            d = ana.type.dict();
            d.answer = 42;
            d("matrix") = magic(3);

            testCase.verifyEqual(d.answer, 42);
            testCase.verifyEqual(d("answer"), 42);
            testCase.verifyEqual(d('answer'), 42);
            testCase.verifyEqual(d.matrix, magic(3));
            testCase.verifyEqual(d("matrix"), magic(3));
        end

        function overwriteExistingKey(testCase)
            d = ana.type.dict();
            d.value = 1;
            d("value") = 2;
            d.value = 3;

            testCase.verifyEqual(d("value"), 3);
            testCase.verifyEqual(numel(keys(d)), 1);
        end

        function heterogeneousValues(testCase)
            d = ana.type.dict();
            d("number") = 17;
            d("text") = "hello";
            d("array") = [1 2; 3 4];
            d("cell") = {1, "two"};
            d.empty = [];

            testCase.verifyEqual(d.number, 17);
            testCase.verifyEqual(d.text, "hello");
            testCase.verifyEqual(d.array, [1 2; 3 4]);
            testCase.verifyEqual(d.cell, {1, "two"});
            testCase.verifyTrue(isKey(d, "empty"));
            testCase.verifyEmpty(d("empty"));
        end

        function constructFromStruct(testCase)
            s = struct('answer', 42, 'samples', [10 20 30]);
            d = ana.type.dict(s);

            testCase.verifyEqual(d.answer, 42);
            testCase.verifyEqual(d("samples"), [10 20 30]);
            testCase.verifyEqual(sort(keys(d)), sort(["answer"; "samples"]));
        end

        function constructFromNameValuePairs(testCase)
            d = ana.type.dict("one", 1, "two", [2 3]);

            testCase.verifyEqual(d("one"), 1);
            testCase.verifyEqual(d("two"), [2 3]);
        end

        function constructFromKeyAndValueArrays(testCase)
            d = ana.type.dict(["first", "second"], {42, magic(3)});

            testCase.verifyEqual(d("first"), 42);
            testCase.verifyEqual(d("second"), magic(3));
        end

        function constructFromNumericValueArray(testCase)
            d = ana.type.dict(["a", "b"], [10 20]);

            testCase.verifyEqual(d("a"), 10);
            testCase.verifyEqual(d("b"), 20);
        end

        function singleKeyMatrixConstructor(testCase)
            value = magic(3);
            d = ana.type.dict("matrix", value);

            testCase.verifyEqual(d("matrix"), value);
        end

        function invalidNameValueConstructor(testCase)
            testCase.verifyError( ...
                @() ana.type.dict("a", 1, "b"), ...
                "ANA:type:dict:InvalidConstructor");
        end

        function keyEnumeration(testCase)
            d = ana.type.dict("b", 2, "a", 1);

            testCase.verifyEqual(sort(keys(d)), ["a"; "b"]);
            testCase.verifyEqual(sort(string(fieldnames(d))), ["a"; "b"]);
            testCase.verifyTrue(isKey(d, 'a'));
            testCase.verifyTrue(isfield(d, "b"));
            testCase.verifyFalse(isKey(d, "c"));
        end

        function keysWithNonIdentifierCharacters(testCase)
            d = ana.type.dict();
            names = ["with space", "a.b", "a-b", "a/b"];

            for k = 1:numel(names)
                d(names(k)) = k;
            end

            for k = 1:numel(names)
                testCase.verifyEqual(d(names(k)), k);
                testCase.verifyTrue(isKey(d, names(k)));
            end
        end

        function missingKeys(testCase)
            d = ana.type.dict();

            testCase.verifyError( ...
                @() d("missing"), "ANA:type:dict:NoSuchKey");
            testCase.verifyError( ...
                @() d.missing, "ANA:runtime:fieldNotFound");
        end

        function invalidParenKeys(testCase)
            d = ana.type.dict("a", 1);

            testCase.verifyError( ...
                @() d("a", "b"), "ANA:type:dict:InvalidIndex");
            testCase.verifyError( ...
                @() d(["a", "b"]), "ANA:type:dict:InvalidKey");
        end

        function emptyValueVersusDeletion(testCase)
            d = ana.type.dict();
            d.empty = [];

            testCase.verifyTrue(isKey(d, "empty"));
            testCase.verifyEmpty(d("empty"));

            d("empty") = [];
            testCase.verifyFalse(isKey(d, "empty"));
        end

        function removeByMethod(testCase)
            d = ana.type.dict("keep", 1, "drop", 2);
            d = remove(d, "drop");

            testCase.verifyTrue(isKey(d, "keep"));
            testCase.verifyFalse(isKey(d, "drop"));
        end

        function removeMultipleKeys(testCase)
            d = ana.type.dict("a", 1, "b", 2, "c", 3);
            d = remove(d, ["a", "c"]);

            testCase.verifyEqual(keys(d), "b");
            testCase.verifyEqual(d("b"), 2);
        end

        function rmfieldRemovesKey(testCase)
            % Regression: rmfield should remove the requested key.
            % Current rmfield() neither returns the updated object nor
            % assigns the result of dictionary.remove().
            d = ana.type.dict("keep", 1, "drop", 2);
            d = rmfield(d, "drop");

            testCase.verifyFalse(isKey(d, "drop"));
            testCase.verifyTrue(isKey(d, "keep"));
        end

        function convertToStruct(testCase)
            d = ana.type.dict("alpha", 1, "beta", [2 3]);
            s = struct(d);

            testCase.verifyEqual(s.alpha, 1);
            testCase.verifyEqual(s.beta, [2 3]);
            testCase.verifyEqual(sort(string(fieldnames(s))), ...
                                 sort(string(fieldnames(d))));
        end

        function nestedIndexing(testCase)
            d = ana.type.dict();
            d("node").child = struct('value', 5);

            testCase.verifyEqual(d("node").child.value, 5);
            testCase.verifyEqual(d.node.child.value, 5);

            d.node.child.value = 10;
            testCase.verifyEqual(d("node").child.value, 10);
        end

        function dotIndexingIntoStoredArray(testCase)
            d = ana.type.dict();
            d.array = [10 20 30];

            testCase.verifyEqual(d.array(2), 20);
            d.array(2) = 99;
            testCase.verifyEqual(d("array"), [10 99 30]);
        end

        function methodNamesAreValidKeys(testCase)
            % Plain dot access and parenthesis-key access must return DATA,
            % even for names of public methods (including the constructor).
            names = ["keys", "isKey", "remove", "fieldnames", ...
                     "isfield", "rmfield", "struct", "disp", ...
                     "display", "dict"];
            d = ana.type.dict();

            for k = 1:numel(names)
                d.(names(k)) = k;
            end

            for k = 1:numel(names)
                testCase.verifyEqual(d.(names(k)), k, ...
                    "Dot access failed for key '" + names(k) + "'.");
                testCase.verifyEqual(d(names(k)), k);
            end
            testCase.verifyEqual(sort(keys(d)), sort(names(:)));
        end

        function methodCallsWinOverSameNamedKeys(testCase)
            % A dot followed by parentheses calls the public method,
            % rather than fetching the key with the same name.
            d = ana.type.dict();
            d.keys = "stored keys value";
            d.isKey = "stored isKey value";
            d.fieldnames = "stored fieldnames value";
            d.isfield = "stored isfield value";
            d.struct = "stored struct value";

            testCase.verifyEqual(d.keys, "stored keys value");
            testCase.verifyEqual(d("isKey"), "stored isKey value");

            testCase.verifyEqual(sort(d.keys()), sort(keys(d)));
            testCase.verifyTrue(d.isKey("keys"));
            testCase.verifyTrue(d.isfield("isKey"));
            testCase.verifyEqual(sort(string(d.fieldnames())), ...
                                 sort(string(fieldnames(d))));

            s = d.struct();
            testCase.verifyEqual(s.keys, "stored keys value");
            testCase.verifyEqual(s.struct, "stored struct value");
        end

        function removeMethodCollidingWithKey(testCase)
            d = ana.type.dict();
            d.remove = "stored remove value";
            d.target = 123;

            testCase.verifyEqual(d.remove, "stored remove value");
            d = d.remove("target");
            testCase.verifyFalse(isKey(d, "target"));
            testCase.verifyEqual(d("remove"), "stored remove value");
        end

        function methodNamedKeyCanBeIndexedAsData(testCase)
            % keys() is a method, while keys(2) can index the stored value
            % if the method call is not applicable.
            d = ana.type.dict();
            d.keys = [10 20 30];

            testCase.verifyEqual(d.keys(2), 20);
            testCase.verifyEqual(d("keys"), [10 20 30]);
            testCase.verifyTrue(any(d.keys() == "keys"));
        end

        function privatePropertyNameAsKey(testCase)
            % Parenthesis access remains unambiguous even when a key has
            % the same name as the internal private property.
            d = ana.type.dict();
            d("PrivateData_") = 42;

            testCase.verifyEqual(d("PrivateData_"), 42);
            testCase.verifyTrue(isKey(d, "PrivateData_"));
        end
    end
end
