classdef dict < ana.config.node.base & matlab.mixin.indexing.RedefinesDot
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

            indent_s = pad("", ana.internal.indent("YAML")*level);
            key = keys(obj.PrivateData_);
            N = length(key);
            for i = 1:N
                if (level > 0) && (i == 1) && ~isa(obj.PrivateParent_, "ana.config.node.list")
                    fprintf(fd,"\n");
                end

                if (i == 1) && isa(obj.PrivateParent_, "ana.config.node.list")
                    fprintf(fd, "%s:", key(i));
                else
                    fprintf(fd, "%s%s:", indent_s, key(i));
                end

                try
                    node = obj.PrivateData_(key(i));
                    node{1}.save_(fd,level+1);
                catch me
                    disp(me)
                end
        
                if (i < N) || (level == 0)
                    fprintf(fd, "\n");
                end
            end
        end        
    end
    
    %% SCHEME
    methods (Access = protected)
        function init(obj)
            sch = obj.PrivateScheme_;

            content = sch.content();
            for k = 1:numel(content)
                child = content{k};

                key = child.key;
                switch(child.type)
                    case 'dict'
                        value = ana.config.node.dict(Parent=obj,Scheme=child);
                    case 'list'
                        value = ana.config.node.list(Parent=obj,Scheme=child,Uniform=false);
                    case 'table'
                        value = ana.config.node.list(Parent=obj,Scheme=child,Uniform=true);
                    otherwise
                        value = ana.config.node.leaf(Parent=obj,Scheme=child);
                end

                obj.PrivateData_(key) = {value};
            end

            obj.apply();
        end

        function [value,msg] = validate(obj,value,key)
            msg = [];
            sch = obj.PrivateScheme_.get(key);
            if isempty(sch)
                msg = sprintf("invalid key: %s", string(key));
                return
            end

            function [valid,reason] = validate(obj,key)
                valid = false;
                reason = "don't know";            
            end        
        end        
    end

    %% RedefinesDot
    methods(Access=protected)
        function res = getField(obj,field)
            res = obj.PrivateData_(field);
            res = res{1};
        end

        function varargout = dotReference(obj, indexOp)
            field = indexOp(1).Name;
            
            if isKey(obj.PrivateData_, field)
                retval = obj.getField(field);
                
                if numel(indexOp) > 1
                    retval = retval.(indexOp(2:end));
                end

                varargout{1} = retval;
            else
                error("ANA:runtime:fieldNotFound', 'Field ''%s'' not found.', field);
            end
        end
        
        function obj = dotAssign(obj, indexOp, varargin)
            field = indexOp(1).Name;
            newValue = varargin{1};
            
            if isscalar(indexOp)
                obj.set(field, newValue);
            else
                % FIXME multiple indexOp, need to handle scheme
                if isKey(obj.PrivateData_, field)
                    currentValue = obj.getField(field);
                else
                    if obj.hasscheme()
                        FIXME
                    else
                        currentValue = ana.config.node.dict(Parent=obj);
                    end
                end
                
                try
                    currentValue.(indexOp(2:end)) = newValue;
                    if obj.hasscheme()
                        FIXME
                    else
                        obj.set(field,currentValue);
                    end
                catch ME
                    rethrow(ME);
                end
            end
        end
        
        function n = dotListLength(obj, indexOp, indexContext)
            field = indexOp(1).Name;
            
            if isKey(obj.PrivateData_, field)
                value = obj.getField(field);
                
                if numel(indexOp) > 1
                    n = matlab.mixin.indexing.RedefinesDot.dotListLength(value, ...
                        indexOp(2:end), indexContext);
                else
                    n = length(value);
                end
            else
                error("ANA:runtime:invalidKey", "Field '%s' not found.", field);
            end
        end
    end
    
    methods
        function fields = fieldnames(obj)
            fields = keys(obj.PrivateData_);
        end
        
        function tf = isfield(obj, field)
            tf = isKey(obj.PrivateData_, field);
        end
        
        function obj = rmfield(obj, field)
            if isKey(obj.PrivateData_, field)
                remove(obj.PrivateData_, field);
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

            obj.PrivateData_ = dictionary(string([]), {});
            obj.init();
        end

        function res = get(obj)
            %GET    Get content as Matlab value.
            %
            try
                res = struct();
                fn = keys(obj.PrivateData_);
                for k = 1:numel(fn)
                    node = obj.PrivateData_(fn{k});
                    res.(fn{k}) = node{1}.get();
                end
            catch 
                res = obj.PrivateData_;
                for k = 1:numel(res)
                    if ~isa(res(fn{k}), 'ana.config.node.base')
                        warning("field %s is not a config node", fn{k})
                    else
                        res(fn{k}) = res(fn{k}).get();
                    end
                end
            end
        end              

        function set(obj,varargin)
            %SET    Set key-value pairs.
            %
            %   node.set(key,value,...)
            %   node.set(key=value,...)
            %   node.set(struct)
            %
            if isscalar(varargin)
                s = varargin{1};
                if isstruct(s)
                    fn = fieldnames(s);
                    for k = 1:numel(fn)
                        obj.set(fn{k},s.(fn{k}))
                    end
                else
                    FIXME
                end
            elseif bitand(numel(varargin),1) == 0
                for k = 1:2:nargin-1
                    key = varargin{k};
                    value = varargin{k+1};

                    FIXME obj.PrivateData_(key) might be already there, then, set() must be used
                    [value,msg] = obj.validate(value,key);
                    if ~isempty(msg)
                        % FIXME be more elaborate...
                        error("ANA:runtime", msg)
                    end
                    
                    obj.PrivateData_(key) = {value};
                end
            else
                error("ANA:runtime:invalidArgument", "invalid arguments")
            end

            obj.autosave();
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
