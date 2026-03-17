classdef mapping < matlab.mixin.indexing.RedefinesDot
    %MAPPING    Dictionary with struct-like data access.
    %
    %   Detailed explanation goes here

    %% PROPERTIES
    properties(Hidden,Access=protected)
        PrivateData_ = dictionary(string([]), {});
    end

    %% RedefinesDot
    methods(Access=protected)
        function retval = dotReferenceField(obj,field)
            assert(isKey(obj.PrivateData_, field));
            retval = obj.PrivateData_(field);
            retval = retval{1};
        end

        function varargout = dotReference(obj, indexOp)
            field = indexOp(1).Name;
            
            if isKey(obj.PrivateData_, field)
                retval = obj.dotReferenceField(field);
                
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
            newValue = varargin(1);
            
            if isscalar(indexOp)
                obj.PrivateData_(field) = newValue;
            else
                if isKey(obj.PrivateData_, field)
                    currentValue = obj.PrivateData_(field);
                else
                    currentValue = ana.util.mapping();
                end
                
                try
                    currentValue.(indexOp(2:end)) = newValue;
                    obj.PrivateData_(field) = currentValue;
                catch ME
                    rethrow(ME);
                end
            end
        end
        
        function n = dotListLength(obj, indexOp, indexContext)
            field = indexOp(1).Name;
            
            if isKey(obj.PrivateData_, field)
                value = obj.dotReferenceField(field);
                
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
        function obj = mapping()
            %MAPPING Construct an instance of this class
        end
    end
end
