classdef carray < matlab.mixin.indexing.RedefinesParen
    %ana.util.carray    Demo class for implementing "RedefinesParen", storing data in a cell internally.
    %
    
    %% PROPERTIES
    properties (Access = private)
        data  % Internal cell array storing the actual data
    end

    %% RedefinesParen
    methods 
        % Optional: Customize how the object is displayed
        function disp(obj)
            fprintf('%s with properties:\n', class(obj));
            fprintf('  Size: [%s]\n', num2str(size(obj)));
            
            if ~isempty(obj.data)
                fprintf('  Contents (internal cell array):\n');
                
                % Show a preview of the data
                maxDisplay = 5; 
                dims = size(obj.data);
                
                if numel(dims) == 2
                    % 2D display
                    for i = 1:min(dims(1), maxDisplay)
                        rowStr = ''; %#ok<*AGROW>
                        for j = 1:min(dims(2), maxDisplay)
                            elem = obj.data{i,j};
                            elemStr = getElementDisplay(elem);
                            rowStr = [rowStr sprintf(' [%s]', elemStr)];
                        end
                        if dims(2) > maxDisplay
                            rowStr = [rowStr ' ...'];
                        end
                        fprintf('    %s\n', rowStr);
                    end
                    if dims(1) > maxDisplay
                        fprintf('    ...\n');
                    end
                else
                    % ND display
                    fprintf('    [%d-D array with %d elements]\n', ndims(obj.data), numel(obj.data));
                end
            else
                fprintf('  Empty array\n');
            end
            
            function str = getElementDisplay(elem)
                if iscell(elem)
                    str = '{cell}';
                elseif ischar(elem)
                    if length(elem) > 10
                        str = ['''' elem(1:7) '...'''];
                    else
                        str = ['''' elem ''''];
                    end
                elseif isnumeric(elem) && isscalar(elem)
                    str = num2str(elem);
                elseif isa(elem, 'function_handle')
                    str = func2str(elem);
                else
                    str = class(elem);
                end
            end
        end
    end

    methods
        function sz = size(obj, varargin)
            if nargin == 1
                sz = size(obj.data);
            else
                sz = size(obj.data, varargin{:});
            end
        end
        
        function n = numel(obj)
            n = numel(obj.data);
        end
        
        function ind = end(obj, k, n)
            sz = size(obj.data);
            if k <= length(sz)
                ind = sz(k);
            else
                ind = 1;
            end
        end

        function tf = isempty(obj)
            tf = isempty(obj.data);
        end
        
        function n = ndims(obj)
            n = ndims(obj.data);
        end
        
        function l = length(obj)
            l = length(obj.data);
        end
    end

    methods (Static)
        function obj = cat(dim, varargin)
            % Concatenate carray objects along specified dimension
            % Usage: carray.cat(dim, arr1, arr2, ...)
            
            % Filter out empty arguments
            arrays = varargin(~cellfun(@isempty, varargin));
            
            if isempty(arrays)
                % No non-empty arrays to concatenate
                obj = carray.empty();
                return;
            end
            
            % Check that all inputs are carray objects
            if ~all(cellfun(@(x) isa(x, 'carray'), arrays))
                error('All concatenation inputs must be carray objects');
            end
            
            % Extract internal data from each array
            cellArrays = cellfun(@(x) x.data, arrays, 'UniformOutput', false);
            
            try
                % Perform concatenation on the internal cell arrays
                concatenatedData = cat(dim, cellArrays{:});
                
                % Create new carray object with concatenated data
                obj = carray();
                obj.data = concatenatedData;
            catch ME
                error('Concatenation failed: %s', ME.message);
            end
        end
        
        function obj = horzcat(varargin)
            % Horizontal concatenation
            obj = carray.cat(2, varargin{:});
        end
        1
        function obj = vertcat(varargin)
            % Vertical concatenation
            obj = carray.cat(1, varargin{:});
        end

        function obj = empty(varargin)
            % Create an empty carray with specified dimensions
            % Usage: carray.empty, carray.empty(0,n), carray.empty([m n])
            
            if nargin == 0
                % Create empty 0x0 array
                obj = carray();
            else
                % Validate input
                if nargin == 1 && isnumeric(varargin{1}) && isscalar(varargin{1})
                    % Single dimension - create square matrix
                    dim = varargin{1};
                    if dim == 0
                        obj = carray(0);
                    else
                        error('Empty array cannot have positive dimensions. Use carray(dim) to create non-empty array.');
                    end
                elseif nargin == 1 && isnumeric(varargin{1}) && ~isscalar(varargin{1})
                    % Size vector
                    sz = varargin{1};
                    if all(sz == 0)
                        % All zeros - create empty with these dimensions
                        obj = carray();
                        obj.data = cell(sz);
                    else
                        error('Empty array dimensions must be zero. Got: [%s]', num2str(sz));
                    end
                elseif nargin >= 1 && all(cellfun(@isnumeric, varargin))
                    % Multiple dimensions
                    dims = [varargin{:}];
                    if all(dims == 0)
                        obj = carray();
                        obj.data = cell(dims);
                    else
                        error('Empty array dimensions must all be zero. Got: [%s]', num2str(dims));
                    end
                else
                    error('Invalid arguments for empty method');
                end
            end
        end
    end

    methods (Access = protected)
        function n = parenListLength(obj, indexOp, ctx)
            if numel(indexOp) >= 1 && strcmp(indexOp(1).Name, '()')
                n = numel(indexOp(1).Indices);
            else
                n = 1;
            end
        end
        
        function varargout = parenReference(obj, indexOp)
            indices = indexOp(1).Indices;
            
            result = cell2mat(obj.data(indices{:}));
            
            if numel(indexOp) > 1
                result = result.(indexOp(2:end));
            end
            
            varargout{1} = result;
        end
        
        function obj = parenAssign(obj, indexOp, varargin)
            value = varargin{end};
            
            indices = indexOp(1).Indices;
            
            if numel(indexOp) > 1
                if isscalar(indices) && ischar(indices{1}) && strcmp(indices{1}, ':')
                    currentData = obj.data;
                else
                    currentData = obj.data(indices{:});
                end

                if iscell(currentData) && isscalar(currentData)
                    temp = currentData{1};
                    temp = matlab.mixin.indexing.RedefinesParen.parenAssign(temp, indexOp(2:end), value);
                    currentData{1} = temp;
                else
                    currentData = matlab.mixin.indexing.RedefinesParen.parenAssign(currentData, indexOp(2:end), value);
                end
                
                if isscalar(indices) && ischar(indices{1}) && strcmp(indices{1}, ':')
                    obj.data = currentData;
                else
                    obj.data(indices{:}) = currentData;
                end
            else
                if isscalar(indices) && ischar(indices{1}) && strcmp(indices{1}, ':')
                    obj.data = value;
                else
                    try
                        obj.data(indices{:}) = mat2cell(value);
                    catch
                        obj.data(indices{:}) = {value};
                    end
                end
            end
        end
        
        function obj = parenDelete(obj, indexOp)
            indices = indexOp(1).Indices;
            
            if isscalar(indices) && ischar(indices{1}) && strcmp(indices{1}, ':')
                obj.data = cell(0);
            else
                obj.data(indices{:}) = [];
            end
            
            if numel(indexOp) > 1
                error('Nested deletion not supported');
            end
        end

        function varargout = parenListend(obj, indexOp, ctx)
            [varargout{1:nargout}] = obj.parenListLength(indexOp, ctx);
        end        
    end

    %% IMPLEMENTATION
    methods
        function obj = carray(varargin)
            if nargin == 0
                obj.data = cell(0);
            elseif nargin == 1 && isa(varargin{1}, 'carray')
                obj.data = varargin{1}.data;
            elseif nargin == 1 && isnumeric(varargin{1})
                if isscalar(varargin{1})
                    obj.data = cell(varargin{1}, varargin{1});
                else
                    obj.data = cell(varargin{1});
                end
            elseif nargin >= 1
                obj.data = cell(varargin{:});
            end
        end       
    end
end