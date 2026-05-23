classdef map < ana.config.node.common & matlab.mixin.indexing.RedefinesDot
    %ana.config.node.map       Dictionary with struct-like data access.
    %
    %   FIXME

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
                if (level > 0) && (i == 1) && ~isa(obj.PrivateParent_, "ana.config.node.seq")
                    fprintf(fd,"\n");
                end

                if (i == 1) && isa(obj.PrivateParent_, "ana.config.node.seq")
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
        function build(obj,sch)
            arguments
                obj 
                sch = []
            end
        end

        function validate(obj,sch,varargin)
            arguments
                obj 
                sch = []
            end
            arguments (Repeating)
                varargin
            end
        end        
    end

    %% RedefinesDot
    methods(Access=protected)
        function res = getField(obj,field)
            res = obj.PrivateData_(field);
            res = res{1};
        end

        function setField(obj,field,value)
            obj.PrivateData_(field) = {obj.make(value)};
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
                error('ana:config:node:map:FieldNotFound', 'Field ''%s'' not found.', field);
            end
        end
        
        function obj = dotAssign(obj, indexOp, varargin)
            field = indexOp(1).Name;
            newValue = varargin{1};
            
            if isscalar(indexOp)
                % FIXME wrap value
                obj.setField(field, newValue);
            else
                if isKey(obj.PrivateData_, field)
                    currentValue = obj.getField(field);
                else
                    if obj.hasscheme()
                        FIXME
                    else
                        currentValue = ana.config.node.map(Parent=obj);
                    end
                end
                
                try
                    currentValue.(indexOp(2:end)) = newValue;
                    if obj.hasscheme()
                        FIXME
                    else
                        obj.setField(field,currentValue);
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
                error('ana:config:node:map:FieldNotFound', 'Field ''%s'' not found.', field);
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
        function obj = map(options)
            %map            Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            obj@ana.config.node.common(Parent=options.Parent,Scheme=options.Scheme);

            obj.PrivateData_ = dictionary(string([]), {});
        end

        function res = get(obj,varargin)
            try
                res = struct();
                fn = keys(obj.PrivateData_);
                for k = 1:numel(fn)
                    node = obj.PrivateData_(fn{k});
                    res.(fn{k}) = node{1}.get();
                end
            catch(me)
                % struct was not possible, return dictionary
                res = obj.PrivateData_;
            end
        end              

        function set(obj,varargin)
            % FIXME
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
