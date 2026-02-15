classdef searchpath < matlab.mixin.indexing.RedefinesBrace ...
        & matlab.mixin.indexing.RedefinesParen
    %ana.fs.searchpath      Search path.
    %
    %   Trivial implementation of search path using internal cell.
    %
    %   Example:
    %       sp = ana.fs.searchpath('C:', 'D:', "/media/user/disk", "/home/user");
    %       
    %       % add another element
    %       sp{end+1} = "/tmp";
    %
    %       % find a file
    %       f = sp.find('notes.txt');
    %

    properties
        Paths = {};
    end

    methods (Static)
        function out = empty()
            out = ana.fs.searchpath();
        end
    end
    
    methods
        function varargout = size(obj,varargin)
            [varargout{1:nargout}] = size(obj.Paths,varargin{:});
        end

        function cat(~,~)
            error('Parentheses indexing is not supported.');
        end
    end

    methods (Access=protected)
        function varargout = braceReference(obj,indexOp)
            [varargout{1:nargout}] = obj.Paths.(indexOp);
        end

        function obj = braceAssign(obj,indexOp,varargin)
            if isscalar(indexOp)
                [obj.Paths.(indexOp)] = ana.fs.path(varargin{:});
                return;
            else
            end
        end

        function n = braceListLength(obj,indexOp,indexContext)
            n = listLength(obj.Paths,indexOp,indexContext);
        end

        function parenReference(~,~)
            error('Parentheses indexing is not supported.');
        end

        function parenAssign(~,~,~)
            error('Parentheses indexing is not supported.');
        end

        function n = parenListLength(~,~,~)
            n = 1;
        end

        function parenDelete(~,~)
            error('Parentheses indexing is not supported.');
        end
    end

    methods
        function obj = searchpath(varargin)
            %SEARCHPATH     Construct an instance of this class.
            arguments (Repeating)
                varargin
            end

            for i = 1:nargin
                v = varargin{i};

                if iscell(v)
                    v = cellfun(@(p) ana.fs.path(string(p)),v,'UniformOutput',false);
                else
                    v = {ana.fs.path(string(v))};
                end

                obj.Paths = [obj.Paths;v];
            end
        end

        function res = find(obj,path)
            %FIND       Find a file or folder in this search path.
            %
            %
            arguments
                obj ana.fs.searchpath
                path
            end

            if iscell(path)
                res = cell(size(path));
                for i = 1:numel(path)
                    res{i} = obj.find(path{i});
                end
            else
                path = ana.fs.path(path);

                for i = 1:numel(obj.Paths)
                    p = obj.Paths{i} / path;
                    if exist(obj.Paths{i} / path, options.Type)
                        res = obj.Paths{i} / path;
                        return;
                    end
                end

                res = [];
            end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
