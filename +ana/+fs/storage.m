classdef storage
    %ana.fs.storage    Storage search path.
    %
    %   FIXME
    %

    properties(Constant,Hidden)
        Data = ana.util.shared(...
            struct(searchpath=[],...
                partial=false))
    end

    methods(Static)
        function set(varargin)
            %SET    Set storage search path.
            ana.fs.storage.Data.searchpath = ana.fs.searchpath(varargin{:});
        end

        function add(varargin)
            %ADD    Add search paths elements.
            data = ana.fs.storage.Data;
            if isempty(data.paths)
                data.paths = ana.fs.searchpath();
            end
            for i = 1:numel(varargin)
                data.paths{end+1} = varargin{i};
            end
        end

        function res = resolve(path,options)
            %RESOLVE    Resolve storage path.
            %
            %   FIXME
            %
            arguments
                path
                options.Partial = ana.fs.storage.Data.partial;
            end

            ana.init();
            if iscell(path)
                res = cellfun(@(p) resolve(p), path, 'UniformOutput', false);
            else
                data = ana.fs.storage.Data;
                res = data.searchpath.find(path);
                if options.Partial
                    while isempty(res) && (length(path) > 2)
                        path = path(2:end);
                        res = data.searchpath.find(path);
                    end
                end
            end
        end
    end

    methods
        function obj = storage(varargin)
            error("This class only has a static interface.")
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
