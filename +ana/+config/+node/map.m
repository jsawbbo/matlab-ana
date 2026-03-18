classdef map < ana.config.node.common & matlab.mixin.indexing.RedefinesDot
    %ana.config.node.map       Dictionary with struct-like data access.
    %
    %   FIXME

    %% HELPER
    methods (Hidden, Access=protected)
        function save_(obj,fd,level)
            arguments
                obj ana.config.node.map
                fd (1,1) double
                level {mustBeScalarOrEmpty} = 0
            end

            indent_s = pad("", obj.Indent_*level);
            key = keys(obj.Value_);
            N = length(key);
            for i = 1:N
                if (level > 0) && (i == 1)
                    fprintf(fd,"\n");
                end
                fprintf(fd, "%s%s:", indent_s, key(i));

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
    
    %% RedefinesDot
    methods(Access=protected)
        function res = getField(obj,field)
            res = obj.Value_(field);
            res = res{1};
        end

        function setField(obj,field,value)
            obj.Value_(field) = {obj.make(value)};
        end

        function varargout = dotReference(obj, indexOp)
            field = indexOp(1).Name;
            
            if isKey(obj.Value_, field)
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
                if isKey(obj.Value_, field)
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
            
            if isKey(obj.Value_, field)
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
            fields = keys(obj.Value_);
        end
        
        function tf = isfield(obj, field)
            tf = isKey(obj.Value_, field);
        end
        
        function obj = rmfield(obj, field)
            if isKey(obj.Value_, field)
                remove(obj.Value_, field);
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

            obj.Value_ = dictionary(string([]), {});
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
