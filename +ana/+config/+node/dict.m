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

            indent_s = pad("", obj.YAMLIndent_*level);
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
                    obj.getField(key(i)).save_(fd,level+1);
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
        end

        function [value,msg] = validate(obj,value,key)
            sch = obj.PrivateScheme_.get(key);
            if isempty(sch)
                msg = sprintf("invalid key: %s", string(key));
                return
            end

            if ~isa(value,'ana.config.node.base')
                if iscell(value)
                    FIXME() % -> list
                elseif isstruct(value)
                    FIXME % -> dict
                else
                    value = ana.config.node.leaf(value,Parent=obj,Scheme=sch);
                end
            else
                FIXME()
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
                error('ana:config:node:dict:FieldNotFound', 'Field ''%s'' not found.', field);
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
                error('ana:config:node:dict:FieldNotFound', 'Field ''%s'' not found.', field);
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
                    res(fn{k}) = res(fn{k}).get();
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
                end
            elseif bitand(numel(varargin),1) == 0
                for k = 1:2:nargin-1
                    key = varargin{k};
                    value = varargin{k+1};

                    [value,msg] = obj.validate(value,key);
                    if ~isempty(msg)
                        % FIXME be more elaborate...
                        error(msg)
                    end
                    
                    obj.PrivateData_(key) = value;
                end
            else
                error("invalid arguments")
            end

            obj.autosave();
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
