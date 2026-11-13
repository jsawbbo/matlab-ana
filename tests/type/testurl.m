classdef testurl < matlab.unittest.TestCase
    %TESTURL Unit tests for ana.type.url.
    % Run with: runtests('testUrl')

    methods (Test)
        function emptyConstructor(testCase)
            u = ana.type.url();
            testCase.verifyClass(u, 'ana.type.url');
            testCase.verifyEqual(string(u), "");
            testCase.verifyEmpty(u.Scheme);
            testCase.verifyEmpty(u.Host);
            testCase.verifyEqual(string(u.Path), "");
        end

        function ordinaryPath(testCase)
            u = ana.type.url("relative/to/file.dat");
            testCase.verifyEmpty(u.Scheme);
            testCase.verifyEmpty(u.Host);
            testCase.verifyEqual(string(u.Path), "relative/to/file.dat");
            testCase.verifyEqual(string(u), "relative/to/file.dat");
        end

        function windowsDriveIsNotScheme(testCase)
            u = ana.type.url("C:\data\file.dat");
            testCase.verifyEmpty(u.Scheme);
            testCase.verifyEqual(string(u.Path), "C:\data\file.dat");
            testCase.verifyEqual(string(u), "C:\data\file.dat");
        end

        function urlWithHostAndPath(testCase)
            u = ana.type.url("https://example.org/data/file.dat");
            testCase.verifyEqual(string(u.Scheme), "https");
            testCase.verifyEqual(string(u.Host), "example.org");
            testCase.verifyEmpty(u.Userinfo);
            testCase.verifyEmpty(u.Port);
            testCase.verifyEqual(string(u.Path), "data/file.dat");
            testCase.verifyEqual(string(u), "https://example.org/data/file.dat");
        end

        function urlWithAuthorityOnly(testCase)
            u = ana.type.url("https://example.org");
            testCase.verifyEqual(string(u.Host), "example.org");
            testCase.verifyEqual(string(u), "https://example.org");
        end

        function urlWithUserinfoAndPort(testCase)
            u = ana.type.url("ftp://user:secret@example.org:2121/archive");
            testCase.verifyEqual(string(u.Scheme), "ftp");
            testCase.verifyEqual(string(u.Userinfo), "user:secret");
            testCase.verifyEqual(string(u.Host), "example.org");
            testCase.verifyEqual(u.Port, 2121);
            testCase.verifyEqual(string(u.Path), "archive");
            testCase.verifyEqual(string(u), "ftp://user:secret@example.org:2121/archive");
        end

        function schemeWithoutAuthority(testCase)
            u = ana.type.url("file:/tmp/data.bin");
            testCase.verifyEqual(string(u.Scheme), "file");
            testCase.verifyEmpty(u.Host);
            testCase.verifyEqual(string(u.Path), "/tmp/data.bin");
            testCase.verifyEqual(string(u), "file:/tmp/data.bin");
        end

        function pathSeparatorsAreCanonicalizedInUrl(testCase)
            u = ana.type.url("file:/tmp\\folder\\data.bin");
            testCase.verifyEqual(string(u.Path), "/tmp/folder/data.bin");
            testCase.verifyEqual(string(u), "file:/tmp/folder/data.bin");
        end

        function uncShare(testCase)
            u = ana.type.url("\\server\folder\file.dat");
            testCase.verifyEqual(string(u.Scheme), "share");
            testCase.verifyEqual(string(u.Host), "server");
            testCase.verifyEqual(string(u.Path), "folder/file.dat");
            testCase.verifyEqual(string(u), "share://server/folder/file.dat");
        end

        function roundTrip(testCase)
            original = "https://user@example.org:8080/a/b";
            u = ana.type.url(original);
            v = ana.type.url(string(u));
            testCase.verifyEqual(string(v), original);
            testCase.verifyEqual(string(v.Scheme), string(u.Scheme));
            testCase.verifyEqual(string(v.Host), string(u.Host));
            testCase.verifyEqual(v.Port, u.Port);
            testCase.verifyEqual(string(v.Path), string(u.Path));
        end

        function queryIsNotYetSupported(testCase)
            testCase.verifyError(@() ana.type.url("https://example.org/a?q=1"), ...
                'ANA:internal');
        end

        function fragmentIsNotYetSupported(testCase)
            testCase.verifyError(@() ana.type.url("https://example.org/a#section"), ...
                'ANA:internal');
        end

        function invalidInputType(testCase)
            % The constructor explicitly rejects non-text, non-path inputs.
            testCase.verifyError(@() ana.type.url(struct('a', 1)), ...
                'MATLAB:assertion:failed');
        end
    end
end
