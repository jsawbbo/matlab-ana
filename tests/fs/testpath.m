classdef testpath < matlab.unittest.TestCase
    %TESTPATH   Contract and regression tests for ana.fs.path.
    %
    % Install as tests/fs/testpath.m.  The existing folder-based runner
    % should discover this class automatically.
    %
    % These tests describe intended behavior, not just current behavior.
    % In particular, root paths, fileparts(), and isurl() may reveal bugs.
    % No global ANA storage configuration is changed by this suite.

    methods (Test)
        %% Construction and normalization
        function defaultConstructorUsesPwd(testCase)
            p = ana.fs.path();
            testCase.verifyClass(p, 'ana.fs.path');
            testCase.verifyEqual(string(p), string(ana.fs.path(pwd)));
        end

        function emptyStringUsesPwd(testCase)
            p = ana.fs.path("");
            testCase.verifyEqual(string(p), string(ana.fs.path(pwd)));
        end

        function copyConstructor(testCase)
            original = ana.fs.path("alpha/beta");
            copied = ana.fs.path(original);
            testCase.verifyClass(copied, 'ana.fs.path');
            testCase.verifyEqual(string(copied), "alpha/beta");
            testCase.verifyTrue(copied == original);
        end

        function charInput(testCase)
            p = ana.fs.path('alpha/beta');
            testCase.verifyEqual(string(p), "alpha/beta");
        end

        function normalizesMixedSeparators(testCase)
            % Backslashes in MATLAB strings/chars are literal characters.
            p = ana.fs.path('alpha//beta\\gamma/');
            testCase.verifyEqual(string(p), "alpha/beta/gamma");
        end

        function removesTrailingSeparator(testCase)
            p = ana.fs.path("alpha/beta/");
            testCase.verifyEqual(string(p), "alpha/beta");
        end

        function absolutePosixPath(testCase)
            p = ana.fs.path("/alpha/beta");
            testCase.verifyEqual(string(p), "/alpha/beta");
            testCase.verifyFalse(isrelative(p));
            testCase.verifyFalse(isshare(p));
        end

        function rootDirectoryRoundTrip(testCase)
            % Regression: a root must not become an empty path string.
            p = ana.fs.path("/");
            testCase.verifyEqual(string(p), "/");
            testCase.verifyFalse(isrelative(p));
        end

        function windowsDrive(testCase)
            p = ana.fs.path('c:\Data\trial.bin');
            testCase.verifyEqual(string(p), "C:/Data/trial.bin");
            testCase.verifyTrue(p.Drive);
            testCase.verifyEqual(string(drive(p)), "C:");
            testCase.verifyFalse(isrelative(p));
            testCase.verifyFalse(isshare(p));
        end

        function uncShare(testCase)
            p = ana.fs.path('\\server\share\trial.bin');
            testCase.verifyEqual(string(p), "//server/share/trial.bin");
            testCase.verifyTrue(isshare(p));
            testCase.verifyFalse(isrelative(p));
        end

        function relativePath(testCase)
            p = ana.fs.path("alpha/beta");
            testCase.verifyTrue(isrelative(p));
            testCase.verifyFalse(isshare(p));
            testCase.verifyEmpty(drive(p));
        end

        function recognizesAliasAtBeginning(testCase)
            p = ana.fs.path("{storage}/session/recording.dat");
            testCase.verifyTrue(isalias(p));
            testCase.verifyEqual(string(alias(p)), "storage");
            testCase.verifyTrue(isrelative(p));
        end

        function bracesElsewhereAreNotAliases(testCase)
            p = ana.fs.path("data/{storage}/file.bin");
            testCase.verifyFalse(isalias(p));
            testCase.verifyEmpty(alias(p));
        end

        function constructFromFileUrl(testCase)
            % A single-slash file: URI keeps its absolute POSIX path.
            u = ana.type.url("file:/alpha/beta.dat");
            p = ana.fs.path(u);
            testCase.verifyEqual(string(p), "/alpha/beta.dat");
            testCase.verifyFalse(isrelative(p));
        end

        function constructFromShareUrl(testCase)
            u = ana.type.url("//server/share/file.bin");
            p = ana.fs.path(u);
            testCase.verifyEqual(string(p), "//server/share/file.bin");
            testCase.verifyTrue(isshare(p));
        end

        function rejectsNonFilesystemUrl(testCase)
            u = ana.type.url("https://example.org/data");
            testCase.verifyError(@() ana.fs.path(u), "ANA:runtime");
        end

        %% Composition and operators
        function joinsRelativePath(testCase)
            p = ana.fs.path("alpha") / "beta";
            testCase.verifyEqual(string(p), "alpha/beta");
        end

        function joinsSeveralComponents(testCase)
            p = ana.fs.path("alpha");
            testCase.verifyEqual(string(fullfile(p, "beta", "gamma.bin")), ...
                "alpha/beta/gamma.bin");
            testCase.verifyEqual(string(p), "alpha");
        end

        function appendsToAbsolutePath(testCase)
            p = ana.fs.path("/alpha") / "beta";
            testCase.verifyEqual(string(p), "/alpha/beta");
            testCase.verifyFalse(isrelative(p));
        end

        function joinsPathInstance(testCase)
            p = ana.fs.path("alpha") / ana.fs.path("beta/gamma");
            testCase.verifyEqual(string(p), "alpha/beta/gamma");
        end

        function backslashOperatorAlsoJoins(testCase)
            p = ana.fs.path("alpha") \ "beta";
            testCase.verifyEqual(string(p), "alpha/beta");
        end

        function rejectsAbsoluteChild(testCase)
            base = ana.fs.path("alpha");
            testCase.verifyError(@() base / "/beta", "ANA:runtime");
        end

        function rejectsDriveChild(testCase)
            base = ana.fs.path("alpha");
            testCase.verifyError(@() base / "C:/beta", "ANA:runtime");
        end

        function rejectsShareChild(testCase)
            base = ana.fs.path("alpha");
            testCase.verifyError(@() base / "//server/share", "ANA:runtime");
        end

        function concatenatesRelativePaths(testCase)
            p = cat(2, ana.fs.path("alpha"), ...
                ana.fs.path("beta"), "gamma");
            testCase.verifyEqual(string(p), "alpha/beta/gamma");
        end

        function rejectsAbsoluteConcatenation(testCase)
            base = ana.fs.path("alpha");
            testCase.verifyError(@() cat(2, base, "/beta"), "ANA:runtime");
        end

        function appendsFilenameSuffix(testCase)
            original = ana.fs.path("alpha/trial");
            updated = original + ".mat";
            testCase.verifyEqual(string(updated), "alpha/trial.mat");
            testCase.verifyEqual(string(original), "alpha/trial");
        end

        %% Indexing and equality
        function sizeCountsPathParts(testCase)
            p = ana.fs.path("alpha/beta/gamma");
            testCase.verifyEqual(size(p), [1 3]);
        end

        function referenceOnePart(testCase)
            p = ana.fs.path("alpha/beta/gamma");
            part = p(2);
            testCase.verifyClass(part, 'ana.fs.path');
            testCase.verifyEqual(string(part), "beta");
        end

        function referencePartRange(testCase)
            p = ana.fs.path("alpha/beta/gamma");
            tail = p(2:3);
            testCase.verifyEqual(string(tail), "beta/gamma");
            testCase.verifyEqual(string(p), "alpha/beta/gamma");
        end

        function referenceRangeUsingEnd(testCase)
            p = ana.fs.path("alpha/beta/gamma/delta");
            tail = p(3:end);
            testCase.verifyEqual(string(tail), "gamma/delta");
        end

        function assignPart(testCase)
            p = ana.fs.path("alpha/beta/gamma");
            p(2) = "delta";
            testCase.verifyEqual(string(p), "alpha/delta/gamma");
        end

        function deletePart(testCase)
            p = ana.fs.path("alpha/beta/gamma");
            p(2) = [];
            testCase.verifyEqual(string(p), "alpha/gamma");
        end

        function partAssignmentHasValueSemantics(testCase)
            original = ana.fs.path("alpha/beta");
            changed = original;
            changed(2) = "gamma";
            testCase.verifyEqual(string(original), "alpha/beta");
            testCase.verifyEqual(string(changed), "alpha/gamma");
        end

        function equalPaths(testCase)
            p = ana.fs.path("alpha/beta");
            testCase.verifyTrue(p == ana.fs.path("alpha/beta"));
            testCase.verifyTrue(p == "alpha/beta");
        end

        function differentNamesAreNotEqual(testCase)
            testCase.verifyFalse(ana.fs.path("alpha/beta") == ...
                ana.fs.path("alpha/gamma"));
        end

        function differentPartCountsAreNotEqual(testCase)
            % Regression: unequal lengths should return false, not error.
            testCase.verifyFalse(ana.fs.path("alpha/beta") == ...
                ana.fs.path("alpha/beta/gamma"));
        end

        function driveLetterCaseIsNormalized(testCase)
            testCase.verifyTrue(ana.fs.path("c:/folder/file.bin") == ...
                ana.fs.path("C:/folder/file.bin"));
        end

        %% Fileparts and predicates
        function filepartsWithoutExtension(testCase)
            p = ana.fs.path("alpha/beta/file");
            [parent, name, ext] = fileparts(p);
            testCase.verifyEqual(string(parent), "alpha/beta");
            testCase.verifyEqual(string(name), "file");
            testCase.verifyEqual(string(ext), "");
        end

        function filepartsWithExtension(testCase)
            % The class documentation promises MATLAB fileparts semantics.
            p = ana.fs.path("alpha/beta/file.tar.gz");
            [parent, name, ext] = fileparts(p);
            testCase.verifyEqual(string(parent), "alpha/beta");
            testCase.verifyEqual(string(name), "file.tar");
            testCase.verifyEqual(string(ext), ".gz");
        end

        function isurlReturnsLogicalTrue(testCase)
            p = ana.fs.path("ssh:/host/data");
            testCase.verifyEqual(isurl(p), true);
        end

        function isurlReturnsLogicalFalse(testCase)
            p = ana.fs.path("alpha/beta");
            testCase.verifyEqual(isurl(p), false);
        end

        %% Filesystem interaction (isolated; no hard-coded local paths)
        function checksExistingFileAndFolder(testCase)
            fixture = testCase.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);
            folder = fixture.Folder;
            name = fullfile(folder, 'trial.dat');
            fid = fopen(name, 'w');
            testCase.assertGreaterThan(fid, 0);
            fclose(fid);

            filePath = ana.fs.path(name);
            folderPath = ana.fs.path(folder);
            testCase.verifyTrue(isfile(filePath));
            testCase.verifyFalse(isfolder(filePath));
            testCase.verifyEqual(exist(filePath, 'file'), 2);
            testCase.verifyTrue(isfolder(folderPath));
            testCase.verifyFalse(isfile(folderPath));
            testCase.verifyEqual(exist(folderPath, 'dir'), 7);
        end

        function checksMissingFile(testCase)
            fixture = testCase.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);
            p = ana.fs.path(fullfile(fixture.Folder, 'missing.dat'));
            testCase.verifyFalse(isfile(p));
            testCase.verifyFalse(isfolder(p));
            testCase.verifyEqual(exist(p, 'file'), 0);
        end

        function locatesAbsolutePathWithoutSearch(testCase)
            p = ana.fs.path("/alpha/beta.dat");
            located = locate(p);
            testCase.verifyClass(located, 'ana.fs.path');
            testCase.verifyEqual(string(located), string(p));
        end

        function locatesRelativeFileUsingExplicitSearchPath(testCase)
            fixture = testCase.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);
            folder = fixture.Folder;
            name = fullfile(folder, 'trial.dat');
            fid = fopen(name, 'w');
            testCase.assertGreaterThan(fid, 0);
            fclose(fid);

            sp = ana.fs.searchpath(folder);
            located = locate(ana.fs.path("trial.dat"), SearchPath=sp);
            testCase.assertClass(located, 'ana.fs.path');
            testCase.verifyEqual(string(located), string(ana.fs.path(name)));
        end

        function missingFileInExplicitSearchPath(testCase)
            fixture = testCase.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);
            sp = ana.fs.searchpath(fixture.Folder);
            located = locate(ana.fs.path("does-not-exist.dat"), ...
                SearchPath=sp);
            testCase.verifyEmpty(located);
        end
    end
end
