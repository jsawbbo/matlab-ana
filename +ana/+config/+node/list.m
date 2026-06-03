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
                    if level > 0
                        indent_s = pad("", ana.internal.indent("YAML")*(level-1));
                        fprintf(fd, "\n%s",indent_s);
                    end

                    fprintf(fd, "-%s",  pad("", ana.internal.indent("YAML")-1));
                    node = obj.PrivateData_{k};
                    node.save_(fd,level);
                    fprintf(fd, "\n");
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
    methods (Access=protected)
        function varargout = parenReference(obj, indexOp)
            idx = indexOp(1).Indices;
            selected = obj.Items(idx{:});

            if isscalar(selected)
                result = selected{1};
            else
                result = vals;
            end

            if isscalar(indexOp)
                varargout{1} = result;
            else
                varargout{1} = matlab.mixin.indexing.forwarding ...
                    .builtinSubsref(result, indexOp(2:end));
            end
        end

        function obj = parenAssign(obj, indexOp, varargin)
            idx = [indexOp(1).Indices{:}];
            value = varargin{1};
            assert(numel(idx) == numel(value));

            if isscalar(indexOp)
                if isscalar(value)
                    if isa(value,'ana.config.node.base')
                        value = value.get();
                    end
                    obj.set(idx,value);
                else
                    for k = 1:numel(idx)
                        if isa(value,'ana.config.node.base')
                            value{k} = value{k}.get();
                        end
                        obj.set(idx(k),value{k});
                    end
                end
            else
                tmp = obj.PrivateData_{idx};
                tmp = matlab.mixin.indexing.forwarding ...
                    .builtinSubsasgn(tmp, indexOp(2:end), varargin{:});
                obj.Items{idx}.set(tmp);
            end
        end

        function obj = parenDelete(obj, indexOp)
            obj.PrivateData_(indexOp.Indices{:}) = [];
        end

        function n = parenListLength(~, indexOp, ~)
            n = numel(indexOp(1).Indices{:});
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
            %   inserts individual values at given index.
            %
            %     node.set({value,...})
            %
            %   resets the list and stores the values in the list.
            %

            sch = obj.PrivateScheme_;

            if isscalar(varargin)
                s = varargin{1};
                if iscell(s)
                    obj.initialize();
                    
                    for k = 1:numel(s)
                        value = s{k};

                        [valid,msg] = obj.validate(value);
                        if ~valid
                            error("ANA:runtime:validationFailed", msg)
                        end

                        obj.PrivateData_{k} = ana.config.node.leaf(value, Parent = obj, Scheme=sch);
                    end
                else
                    error("ANA:logic:invalidArgument", "argument not recognized")
                end
            elseif bitand(numel(varargin),1) == 0
                for k = 1:2:nargin-1
                    idx = varargin{k};
                    value = varargin{k+1};

                    if idx > numel(obj)+1
                        error("ANA:runtime:invalidIndex", "index out of range")
                    end

                    [valid,msg] = obj.validate(value);
                    if ~valid
                        error("ANA:runtime:validationFailed", msg)
                    end
                    
                    obj.PrivateData_{idx} = ana.config.node.leaf(value, Parent = obj, Scheme=sch);
                end
            else
                error("ANA:runtime:invalidArgument", "invalid arguments")
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
%   DeepSeek (深度求索)
