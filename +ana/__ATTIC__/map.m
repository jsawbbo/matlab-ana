classdef map < matlab.mixin.indexing.RedefinesDot
    %ana.util.map       Equivalent of struct/struct-array based on Matlab's dictionary.
    %
    %   FIXME
    %

    %% PROPERTIES
    properties(Hidden,Access=protected)
        PrivateData_ = dictionary(string([]), {});
    end

    %% INTERNAL
    methods (Access = protected)
    end

    %% RedefinesDot
    methods(Access=protected)
        function varargout = dotReference(obj, indexOp)
            if obj.isarray()
                FIXME
            else
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
        end
        
        function obj = dotAssign(obj, indexOp, varargin)
            if obj.isarray()
                FIXME
            else
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
        function res = isarray(obj)
            %isarray        Check if map behaves like an array.
            res = iscell(obj.PrivateData_);
        end

        function obj = makeArray(obj,rows,cols)
            %makeArray      Convert to array (keeping (1,1)).
            arguments
                obj (1,1) ana.util.map
                rows (1,1) {mustBeInteger}
                cols (1,1) {mustBeInteger} = 1
            end

            assert(rows*cols>0, "ana:util:map:InvalidRowsColumns", "Invalid number of rows and/or columns requested.");

            tmp = obj.PrivateData_;
            wasarray = obj.isarray();

            obj.PrivateData_ = cell(rows,cols);

            if wasarray 
                for r = 1:size(tmp,1)
                    for c = 1:size(tmp,2)
                        obj.PrivateData_{r,c} = tmp{r,c};
                    end
                end
            else
                obj.PrivateData_{1,1} = tmp;
            end

            for i = 1:rows*cols
                if isempty(obj.PrivateData_{i})
                    obj.PrivateData_{i} = dictionary(string([]), {});
                end
            end
        end
        
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
        function obj = map(varargin)
            %ana.util.map   Construct an instance of this class
            if nargin == 0
            elseif nargin == 1
                if isnumeric(varargin{1})
                    obj.PrivateData_ = cell(1,varargin{1});
                    for i = 1:varargin{1}
                        obj.PrivateData_{i} = dictionary(string([]), {});
                    end
                else
                    FIXME
                end
            else
                FIXME
            end
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
