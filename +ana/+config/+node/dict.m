classdef dict < ana.config.node.base & matlab.mixin.indexing.RedefinesDot & matlab.mixin.Scalar
    %ana.config.node.dict       A key-value pair mapping.
    %
    %   This node wraps an underlying dictionary, allowing non-standard keys. If possible, though,
    %   it may behave like a normal `struct` for accessing values.
    %

    %% HELPER
    methods (Hidden, Access=protected)
        function save_(obj,fd,level)
            arguments
                obj
                fd (1,1) double
                level {mustBeScalarOrEmpty} = 0
            end

            parent_list = isa(obj.PrivateParent_, "ana.config.node.list") || isa(obj.PrivateParent_, "ana.config.node.table");
            indent_s = pad("", ana.internal.indent("YAML")*level);
            key = fieldnames(obj.PrivateData_);
            N = length(key);
            for i = 1:N
                if (level > 0) && (i == 1) && ~parent_list
                    fprintf(fd,"\n");
                end

                if (i == 1) && parent_list
                    fprintf(fd, "%s:", key{i});
                else
                    fprintf(fd, "%s%s:", indent_s, key{i});
                end

                try
                    obj.PrivateData_(key{i}).save_(fd,level+1);
                catch me
                    FIXME(me)
                end
        
                if (i < N) || (level == 0)
                    fprintf(fd, "\n");
                end
            end
        end        
    end
    
    %% SCHEME
    methods (Access = protected)
        function initialize(obj)
            obj.PrivateData_ = ana.type.dict;
            if ~isempty(obj.PrivateScheme_)
                content = obj.PrivateScheme_.content();
                for k = 1:numel(content)
                    child = content{k};

                    switch (child.type)
                        case "dict"
                            node = ana.config.node.dict(Parent=obj,Scheme=child);
                        case "table"
                            node = ana.config.node.table(Parent=obj,Scheme=child);
                        case "list"
                            node = ana.config.node.list(Parent=obj,Scheme=child);
                        otherwise
                            node = ana.config.node.leaf(Parent=obj,Scheme=child);
                    end

                    obj.PrivateData_(child.key) = node;
                end
            end
        end

        function [valid,reason] = validate(obj,key)
            reason = [];
            sch = obj.PrivateScheme_;
            if isempty(sch)
                valid = true;
            else
                valid = ~isempty(sch.get(key));
                if ~valid
                    reason = sprintf("key '%s' is not in scheme", key);
                end
            end
        end        
    end

    %% RedefinesDot
    methods(Access=protected)
        function varargout = dotReference(obj, indexOp)
            field = indexOp(1).Name;
            
            if isfield(obj.PrivateData_, field)
                retval = obj.PrivateData_(field);
                
                if numel(indexOp) > 1
                    retval = retval.(indexOp(2:end));
                end

                varargout{1} = retval;
            else
                error("ANA:runtime:fieldNotFound", "field '%s' not found.", field);
            end
        end
        
        function obj = dotAssign(obj, indexOp, varargin)
            field = indexOp(1).Name;
            newValue = varargin{1};

            if isscalar(indexOp)
                obj.set(field, newValue);
            else
                node = obj.PrivateData_(field);
                node.(indexOp(2:end)) = newValue;
            end
        end
        
        function n = dotListLength(obj, indexOp, ~)
            field = indexOp(1).Name;
            if isfield(obj.PrivateData_, field)
                % always returning one node
                n = 1;
            else
                error("ANA:runtime:invalidKey", "Field '%s' not found.", field);
            end
        end
    end
    
    methods
        function fields = fieldnames(obj)
            fields = fieldnames(obj.PrivateData_);
        end
        
        function tf = isfield(obj, field)
            tf = isfield(obj.PrivateData_, field);
        end
        
        function obj = rmfield(obj, field)
            if isfield(obj.PrivateData_, field)
                obj.PrivateData_ = rmfield(obj.PrivateData_, field);
            end
        end
    end
    
    %% PUBLIC
    methods
        function obj = dict(options)
            %DICT           Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            obj@ana.config.node.base(Parent=options.Parent,Scheme=options.Scheme);
            obj.initialize();
        end

        function res = get(obj)
            %GET    Get content as Matlab value.
            %
            try
                res = struct();
                fn = fieldnames(obj.PrivateData_);
                for k = 1:numel(fn)
                    node = obj.PrivateData_(fn{k});
                    res.(fn{k}) = node{1}.get();
                end
            catch 
                res = obj.PrivateData_;
                for k = 1:numel(fn)
                    if ~isa(res.(fn{k}), 'ana.config.node.base')
                        warning("field %s is not a config node", fn{k})
                    else
                        res.(fn{k}) = res.(fn{k}).get();
                    end
                end
            end
        end

        function obj = set(obj,varargin)
            %SET    Set key-value pairs.
            %
            % Usage:
            %
            %     node.set(key=value,...)
            %
            %   sets individual key-value pairs in the table.
            %
            %     node.set(struct)
            %     node.set({key=value,...})
            %
            %   resets the map and stores the key-value pairs in the table.
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
                    if isstruct(s) && isscalar(s)
                        obj.initialize();

                        fn = fieldnames(s);
                        for k = 1:numel(fn)
                            obj.set(fn{k},s.(fn{k}));
                        end
                    elseif iscell(s)
                        obj.initialize();
                        
                        obj.set(s{:});
                    else
                        error("ANA:logic:invalidArgument", "argument not recognized")
                    end
                elseif bitand(numel(varargin),1) == 0
                    for k = 1:2:nargin-1
                        key = varargin{k};
                        value = varargin{k+1};
    
                        [valid,msg] = obj.validate(key);
                        if ~valid
                            error("ANA:runtime:validationFailed", msg)
                        end
    
                        if isfield(obj.PrivateData_, key)
                            node = obj.PrivateData_(key);
                            node.set(value);
                        else
                            if isempty(obj.PrivateScheme_)
                                sch = [];
                            else
                                sch = obj.PrivateScheme_.get(key);
                            end
                            
                            T = ana.config.scheme.typeid(value);
                            if isempty(T)
                                if isstruct(value)
                                    node = ana.config.node.dict(Parent=obj,Scheme=sch);
                                    node.set(value);
    
                                    obj.PrivateData_(key) = {node};
                                elseif iscell(value)
                                    node = ana.config.node.list(Parent=obj,Scheme=sch);
                                    node.set(value);
    
                                    obj.PrivateData_(key) = {node};
                                else
                                    error("ANA:runtime:invalidType", "trying to assign invalid type for key '%s'", key)
                                end
                            else
                                obj.PrivateData_(key) = {ana.config.node.leaf(value,Parent=obj,Scheme=sch)};
                            end
                        end
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
