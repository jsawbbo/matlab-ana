classdef map < matlab.mixin.indexing.RedefinesDot
    %ana.util.map       Dictionary with struct-like data access.
    %
    %   This class wraps a dictionary with dot-notation access to fields, as with structs.
    %

    %% PROPERTIES
    properties(Hidden,Access=protected)
        PrivateData_ = dictionary(string([]), {});
    end

    %% RedefinesDot
    methods(Access=protected)
        function varargout = dotReference(obj, indexOp)
            field = indexOp(1).Name;
            
            if isKey(obj.PrivateData_, field)
                retval = obj.get(field);
                
                if numel(indexOp) > 1
                    retval = retval.(indexOp(2:end));
                end

                varargout{1} = retval;
            else
                error('ana:util:mapping:FieldNotFound', 'Field ''%s'' not found.', field);
            end
        end
        
        function obj = dotAssign(obj, indexOp, varargin)
            field = indexOp(1).Name;
            newValue = varargin{1};
            
            if isscalar(indexOp)
                obj = obj.set(field, newValue);
            else
                if isKey(obj.PrivateData_, field)
                    currentValue = obj.get(field);
                else
                    currentValue = ana.util.mapping();
                end
                
                try
                    currentValue.(indexOp(2:end)) = newValue;
                    obj = obj.set(field,currentValue);
                catch ME
                    rethrow(ME);
                end
            end
        end
        
        function n = dotListLength(obj, indexOp, indexContext)
            field = indexOp(1).Name;
            
            if isKey(obj.PrivateData_, field)
                value = obj.get(field);
                
                if numel(indexOp) > 1
                    n = matlab.mixin.indexing.RedefinesDot.dotListLength(value, ...
                        indexOp(2:end), indexContext);
                else
                    n = length(value);
                end
            else
                error('ana:util:mapping:FieldNotFound', 'Field ''%s'' not found.', field);
            end
        end
    end
    
    %% INTERFACE
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
        
        function disp(obj)
            fprintf("  <a href=""matlab:help ana.util.mapping"">ana.util.mapping</a> with fields:\n");
            keysList = keys(obj.PrivateData_);
            for i = 1:length(keysList)
                fprintf('    %s\n', keysList{i});
            end
        end
    end
    
    methods
        function obj = map()
            %ana.util.map   Construct an instance of this class
        end

        function retval = get(obj,field)
            %get            Get content of an existing field.
            arguments
                obj ana.util.map
                field string
            end
            assert(isKey(obj.PrivateData_, field),'ana:util:mapping:FieldNotFound', 'Field ''%s'' not found.', field);
            retval = obj.PrivateData_(field);
            retval = retval{1};
        end

        function obj = set(obj,field,value)
            %set            Set content of a field.
            obj.PrivateData_(field) = {value};
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
