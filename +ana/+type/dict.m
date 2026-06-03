classdef dict < matlab.mixin.indexing.RedefinesParen & matlab.mixin.Scalar
    %ANA.TYPE.DICT      A dictionary with struct semantics.
    %
    %   d = ana.type.dict();
    %   d.foo = 42;
    %   d.("bar-baz") = magic(3);
    %
    %   d.foo         % -> 42
    %   d.("bar-baz") % -> magic(3)
    %   fieldnames(d) % -> {'foo'; 'bar-baz'}
    %
    % Internally values are stored in MATLAB's dictionary using string keys.
    % Values are wrapped in cells so heterogeneous MATLAB values are allowed.

    %% Properties
    properties (Access = private)
        Data dictionary = dictionary(string.empty(1,0), cell.empty(1,0))
    end

    %% Helper
    methods
        function out = keys(obj)
            % keys      Return keys as a string column vector.
            out = keys(obj.Data);
            out = out(:);
        end

        function tf = isKey(obj, name)
            % isKey     True if key exists.
            tf = isKey(obj.Data, string(name));
        end

        function remove(obj, name)
            % remove    Remove one or more keys.
            remove(obj.Data, string(name));
        end
        
        function disp(obj)
            fn = fieldnames(obj);    
            if isempty(fn)
                return
            end
    
            pad = max(cellfun(@length, fn));

            for k = 1:numel(fn)    
                value = obj(fn{k});
    
                fprintf('    %*s: %s\n', ...
                    pad, fn{k}, ana.type.describe(value));
            end

            fprintf('\n');
        end
    
        function display(obj) %#ok<DISPLAY>
            ana.type.display(obj, inputname(1));
        end
    end

    %% PUBLIC
    methods
        function obj = dict(varargin)
            % dict      Construct an ana.type.dict.
            %
            %   d = ana.type.dict()
            %   d = ana.type.dict(s)              % from scalar struct
            %   d = ana.type.dict(keys, values)   % values may be cell array
            %   d = ana.type.dict("a", 1, "b", 2) % name/value pairs

            if nargin == 0
                return
            end

            if nargin == 1 && isstruct(varargin{1})
                s = varargin{1};
                f = string(fieldnames(s));
                for k = reshape(f, 1, [])
                    obj.Data(k) = {s.(k)};
                end
                return
            end

            if nargin == 2 && (isstring(varargin{1}) || iscellstr(varargin{1}))
                ks = string(varargin{1});
                vs = varargin{2};

                if ~iscell(vs)
                    vs = num2cell(vs);
                end

                for i = 1:numel(ks)
                    obj.Data(ks(i)) = {vs{i}};
                end
                return
            end

            if mod(nargin, 2) ~= 0
                error("ANA:type:dict:InvalidConstructor", ...
                    "Name/value construction requires an even number of inputs.");
            end

            for i = 1:2:nargin
                obj.Data(string(varargin{i})) = {varargin{i+1}};
            end
        end

        function out = fieldnames(obj)
            % fieldnames        Return dictionary keys as a cellstr, like struct.
            out = cellstr(keys(obj.Data));
            out = out(:);
        end

        function tf = isfield(obj, name)
            % isfield           True if key exists.
            tf = isKey(obj, name);
        end

        function rmfield(obj, name)
            % rmfield           Remove one or more keys.
            remove(obj.Data, string(name));
        end

        function s = struct(obj)
            % struct            Convert to scalar struct (if possible).
            s = struct();
            ks = keys(obj.Data);
            for k = reshape(ks, 1, [])
                value = obj.Data(k);
                value = value{1};
                s.(k) = value;
            end
        end
    end

    %% RedefinesParen
    methods (Access = protected)
        function varargout = parenReference(obj, indexOp)
            key = ana.type.dict.parseKey(indexOp(1));

            if ~isKey(obj.Data, key)
                error("ANA:type:dict:NoSuchKey", ...
                    "No such key: '%s'.", key);
            end

            value = obj.Data(key);
            value = value{1};

            if isscalar(indexOp)
                varargout{1} = value;
            else
                [varargout{1:nargout}] = value.(indexOp(2:end));
            end
        end

        function obj = parenAssign(obj, indexOp, varargin)
            key = ana.type.dict.parseKey(indexOp(1));

            if isscalar(indexOp)
                obj.Data(key) = varargin(1);
                return
            end

            if isKey(obj.Data, key)
                value = obj.Data(key);
                value = value{1};
            else
                value = struct();
            end

            [value.(indexOp(2:end))] = varargin{:};
            obj.Data(key) = {value};
        end

        function obj = parenDelete(obj, indexOp)
            key = ana.type.dict.parseKey(indexOp(1));
            remove(obj.Data, key);
        end

        function n = parenListLength(obj, indexOp, indexContext)
            key = ana.type.dict.parseKey(indexOp(1));

            if ~isKey(obj.Data, key)
                n = 1;
                return
            end

            value = obj.Data(key);
            value = value{1};

            if isscalar(indexOp)
                n = 1;
            else
                n = listLength(value, indexOp(2:end), indexContext);
            end
        end
    end

    methods (Static, Access = private)
        function key = parseKey(indexOp)
            idx = indexOp.Indices;

            if numel(idx) ~= 1
                error("ANA:type:dict:InvalidIndex", ...
                    "Use exactly one key, for example d(""foo"").");
            end

            key = string(idx{1});

            if ~isscalar(key)
                error("ANA:type:dict:InvalidKey", ...
                    "Dictionary key must be scalar string or char.");
            end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
%
% Development assistance:
%   ChatGPT (OpenAI, GPT-5.5)
