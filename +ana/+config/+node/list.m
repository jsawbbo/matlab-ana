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
        end

        function [valid,reason] = validate(obj,idx)
            reason = [];
            if idx < 1
                valid = false;
            elseif idx > numel(obj.PrivateData_)+1
                valid = false;
            else
                valid = true;
            end

            if ~valid
                reason = "index out of bounds";
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
            % if isscalar(indexOp)
            %     for k = 1:numel(varargin)
            %         varargin{k}.PrivateParent_ = obj;
            %     end
            %     [obj.PrivateData_{indexOp.Indices{:}}] = varargin{:};
            % else
            %     tmp = obj.PrivateData_{indexOp(1).Indices{:}};
            %     tmp.(indexOp(2:end)) = varargin{:};
            %     % obj.PrivateData_{indexOp(1).Indices{:}} = tmp;
            % end
        end

        function obj = parenDelete(obj, indexOp)
            obj.PrivateData_(indexOp.Indices{:}) = [];
        end

        function n = parenListLength(obj, indexOp, ~)
            n = numel(obj.PrivateData_(indexOp.Indices{:}));
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
                options.Uniform = true; % FIXME currently unused
            end

            obj@ana.config.node.base(Parent=options.Parent,Scheme=options.Scheme);
            obj.initialize();
        end

        function res = get(obj,varargin)
            if isempty(obj)
                res = {};
                return;
            end

            try
                res = obj.PrivateData_{1}.get();
                if isstruct(res)
                    for k = 2:numel(obj)
                        res(k) = obj.PrivateData_{k}.get();
                    end
                    return
                end
            catch 
                % not a struct array
            end

            res = cell(numel(obj),1);
            for k = 1:numel(obj)
                res{k} = obj.PrivateData_{k}.get();
            end
        end              

        function obj = set(obj,varargin,options)
            %SET    Set entry.
            %
            % Usage:
            %
            %    node.set(item)
            %    node.set(item, Index=index)
            %    node.set(key=value)
            %    node.set(key=value, Index=index)
            %
            arguments
                obj
            end

            arguments (Repeating)
                varargin
            end

            arguments
                options.Index = []
            end

            idx = options.Index;
            if isempty(idx)
                idx = numel(obj.PrivateData_)+1;
            end
            
            [valid,msg] = obj.validate(idx);
            if ~valid
                error("ANA:runtime:validationFailed", msg)
            end

            

            % if isempty(obj.PrivateScheme_)
            %     for k = 1:narg
            %         value = varargin{k};
            % 
            %         T = ana.config.scheme.typeid(value);
            %         if isempty(T)
            %             if isstruct(value)
            %                 node = ana.config.node.dict(Parent=obj,Scheme=[]);
            %                 node.set(value);
            %             elseif iscell(value)
            %                 node = ana.config.node.list(Parent=obj,Scheme=[]);
            %                 node.set(value);
            %             else
            %                 error("ANA:runtime:invalidType", "trying to assign invalid type for key '%s'", key)
            %             end
            %         else
            %             node = ana.config.node.leaf(value,Parent=obj,Scheme=[]);
            %         end
            % 
            %         obj.PrivateData_{idx+k-1} = node;
            %     end
            % else
            %     FIXME
            % end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
