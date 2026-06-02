classdef list < ana.config.node.base & matlab.mixin.indexing.RedefinesParen
    %ana.config.node.list       Array-like configuration node.
    %
    %   FIXME
    %

    %% HELPER
    methods (Hidden, Access=protected)
        function save_(obj,fd,level)
            arguments
                obj
                fd (1,1) double
                level {mustBeScalarOrEmpty} = 0
            end

            if ~isempty(obj)
                for k = 1:numel(obj)
                    fprintf(fd, "-%s",  pad("", ana.internal.indent("YAML")-1));
                    node = obj.PrivateData_{k};
                    node.save_(fd,level);
                end
            end
        end        
    end
    
    %% SCHEME
    methods (Access = protected)
        function initialize(obj)
            obj.PrivateData_ = {};
            if ~isempty(obj.PrivateScheme_)
                obj.PrivateType_ = obj.PrivateScheme_.type();
                % TODO 
                % - allow a list to have default entries?
            end
        end

        function [valid,reason] = validate(obj,value)
            reason = [];

            T = ana.config.scheme.typeid(value);
            if isempty(obj.PrivateType_)
                obj.PrivateType_ = T;
                valid = true;
            else
                switch (obj.PrivateType_)
                    case "*"
                        valid = true;
                    otherwise
                        valid = strcmp(T, obj.PrivateType_);
                end

                if ~valid
                    reason = "invalid type";
                end
            end
        end        
    end

    %% RedefinesParen
    methods(Access=protected)
        function varargout = parenReference(obj, indexOp)
            [varargout{1:nargout}] = obj.PrivateData_{indexOp(1).Indices{:}};

            if numel(indexOp) > 1
                [varargout{1:nargout}] = matlab.mixin.indexing.internal.forwardIndexing( ...
                    varargout{:}, indexOp(2:end));
            end
        end

        function obj = parenAssign(obj, indexOp, varargin)
            assert(isscalar(indexOp(1).Indices), "mulitple indexes not allowed")

            

            if isscalar(indexOp)
                for k = 1:numel(varargin)
                    varargin{k}.PrivateParent_ = obj;
                end
                [obj.PrivateData_{indexOp.Indices{:}}] = varargin{:};
            else
                tmp = obj.PrivateData_{indexOp(1).Indices{:}};
                tmp.(indexOp(2:end)) = varargin{:};
                % obj.PrivateData_{indexOp(1).Indices{:}} = tmp;
            end
        end

        function obj = parenDelete(obj, indexOp)
            obj.PrivateData_(indexOp.Indices{:}) = [];
        end

        function n = parenListLength(obj, indexOp, ~)
            % FIXME
            n = numel(obj.PrivateData_(indexOp(1).Indices{:}));
        end
    end
    
    methods (Access=public)
        function out = value(obj)
            out = obj.PrivateData_;
        end
        
        function out = cat(dim,varargin)
            error("ANA:internal:requiresImplementation", "Internal error: function or method should but is not implemented.")
        end

        function data = cell(obj)
            data = obj.PrivateData_;
        end

        function n = numel(obj, varargin)
            n = numel(obj.PrivateData_);
        end

        function n = length(obj)
            n = length(obj.PrivateData_);
        end

        function s = size(obj, dim)
            if nargin == 1
                s = size(obj.PrivateData_);
            else
                s = size(obj.PrivateData_, dim);
            end
        end        

        function tf = isempty(obj)
            tf = isempty(obj.PrivateData_);
        end
    end

    methods (Static, Access=public)
        function obj = empty()
            obj = ana.config.node.list();
        end
    end
    
    %% PUBLIC
    methods
        function obj = list(options)
            %SEQ            Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            obj@ana.config.node.base(Parent=options.Parent,Scheme=options.Scheme);
            obj.initialize();
        end

        function res = get(obj,varargin)
            if isempty(obj)
                res = {};
                return;
            end

            res = cell(numel(obj),1);
            for k = 1:numel(obj)
                res{k} = obj.PrivateData_{k}.get();
            end
        end              

        function obj = set(obj,varargin)
            %SET    Set entry.
            %
            % Usage:
            %
            %     node.set(index,value,...)
            %
            %   inserts individual values by index, where negative values count from end
            %   (1 is front, -1 is end), while
            %
            %     node.set({value,...})
            %
            %   resets the list and stores the values in the list.
            %
            persistent scope
            if isempty(scope)
                scope = 0;
            else
                scope = scope + 1;
            end

            try
                if isscalar(varargin)
                    s = varargin{1};
                    if iscell(s)
                        obj.initialize();
                        
                        obj.set(s{:});
                    else
                        error("ANA:logic:invalidArgument", "argument not recognized")
                    end
                elseif bitand(numel(varargin),1) == 0
                    sch = obj.PrivateScheme_;

                    for k = 1:2:nargin-1
                        idx = varargin{k};
                        value = varargin{k+1};
    
                        if idx > numel(obj)+1
                            error("ANA:runtime:invalidIndex", "index out of range")
                        end

                        obj.PrivateData_{idx} = ana.config.node.leaf(value, Parent = obj, Scheme=sch);
                    end
                else
                    error("ANA:runtime:invalidArgument", "invalid arguments")
                end
    
                if scope == 0
                    obj.autosave();
                else
                    scope = scope - 1;
                end
            catch me
                scope = 0;
                rethrow(me);
            end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
