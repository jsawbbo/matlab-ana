classdef url
    %ANA.UTIL.URL    URL scheme
    %
    %   The format of an URL (or URI, respectively) is:
    %
    %       scheme ":" ["//" authority] path ["?" query] ["#" fragment]
    %
    %   where "authority" itself is of the form:
    %
    %       authority = [userinfo "@"] host [":" port]
    %

    properties
        Scheme
        Userinfo
        Host
        Port
        Path
        Query 
        Fragment
    end

    methods
        function res = string(obj)
            %STRING     Create string representation of the URL.
            if ~isempty(obj.Scheme)
                res = string(obj.Scheme) + ":";
            else
                res = "";
            end

            if ~isempty(obj.Host)
                res = res + "//";
            
                if ~isempty(obj.Userinfo)
                    res = res + string(obj.Userinfo) + "@";
                end

                res = res + string(obj.Host);

                if ~isempty(obj.Port)
                    res = res + ":" + string(obj.Port);
                end
            end

            if ~isempty(obj.Path)
                if ~startsWith(obj.Path,"/")
                    res = res + "/";
                end
                res = res + obj.Path;

                if ~isempty(obj.Query)
                    res = res + "?" + string(obj.Query);
                end

                if ~isempty(obj.Fragment)
                    res = res + "#" + string(obj.Fragment);
                end
            end
        end
    end

    methods
        function obj = url(str)
            %URL Construct an instance of this class
            arguments
                str = []
            end

            if isa(str, 'ana.fs.path')
                if str.isshare()
                    str = string(str);
                else
                    obj.Scheme = "file";
                    obj.Path = string(str);
                    return
                end
            elseif isempty(str)
                str = "";
            else 
                assert(ischar(str) || isstring(str))
            end


            % Parse the input string and assign properties
            parts = regexp(str, ':', 'split', 'once');

            if strlength(parts(1)) == 1     % Windows drive letter
                parts = str;
            end

            if numel(parts) > 1
                obj.Scheme = parts(1);

                rest = parts(2);
                if startsWith(rest, '//')
                    rest = extractAfter(parts(2), 2);
                    parts = regexp(rest, '/', 'split', 'once');
                    assert((numel(parts) == 2) || (strlength(parts(1)) > 0), "invalid url");

                    authority = parts(1);
                    if numel(parts) > 1
                        rest = parts(2);
                    else
                        rest = "";
                    end

                    if contains(authority, '@')
                        userinfo = extractBefore(authority, '@');
                        obj.Userinfo = userinfo;
                        authority = extractAfter(authority, '@');
                    else
                        obj.Userinfo = [];
                    end
                    if contains(authority, ':')
                        hostPort = regexp(authority, ':', 'split', 'once');
                        obj.Host = hostPort(1);
                        obj.Port = str2double(hostPort(2));
                    else
                        obj.Host = authority;
                        obj.Port = [];
                    end
                end

                if contains(rest, {'?','#'})
                    error("internal error: query and fragment not supported")
                end

                obj.Path = ana.fs.canonicalize(rest);
            else
                obj.Userinfo = [];
                obj.Host = [];
                obj.Port = [];

                if startsWith(parts, "\\") || startsWith(parts, "//")   % Windows share
                    rest = extractAfter(parts, 2);
                    rest = ana.fs.canonicalize(rest);

                    parts = regexp(rest, '/', 'split', 'once');

                    obj.Scheme = "share";
                    obj.Host = parts(1);
                    obj.Path = parts(2);
                else
                    obj.Path = parts;                       
                end
            end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
