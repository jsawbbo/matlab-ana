function result = parse(s,options)
    %ana.file.yaml.parse    Parse a YAML string.
    %
    %See also: ana.file.yaml.koch.parse
    %
    %Note: This file internally uses Martin Koch's Matlab YAML package,
    %      released under the MIT License.
    arguments
        s (1, 1) string
        options.ConvertToArray (1, 1) logical = true
    end

    ana.init
    import org.yaml.snakeyaml.*;
    try
        rootNode = Yaml().load(s);
    catch cause
        MException("yaml:load:Failed", "Failed to load YAML string.").addCause(cause).throw
    end
    
    try
        result = convert(rootNode, options.ConvertToArray);
    catch exc
        if startsWith(exc.identifier, "yaml:load:")
            error(exc.identifier, exc.message);
        end
        exc.rethrow;
    end
end

function result = convert(node, convertToArray)
    switch class(node)
        case "double" % null is loaded as 0-by-0
            result = node;
        case "char"
            result = string(node);
        case "logical"
            result = logical(node);
        case "java.util.LinkedHashMap"
            result = convertMap(node, convertToArray);
        case "java.util.ArrayList"
            result = convertList(node, convertToArray);
        case "java.util.Date"
            long = node.getTime;
            result = datetime(long, "ConvertFrom", "epochtime", "TicksPerSecond", 1000, "TimeZone", "UTC", "Format", "dd-MMM-uuuu HH:mm:ss.SSS z");
        case "java.math.BigInteger"
            error("yaml:load:IntOutOfRange", "Integer '%s' is out of the supported range.", node.toString())
        otherwise
            error("yaml:load:TypeNotSupported", "Data type '%s' is not supported.", class(node))
    end
end

function result = convertMap(map, convertToArray)
    result = struct();

    keys = string(map.keySet().toArray())';
    if ~all(cellfun(@isvarname,keys))
        result = ana.type.dict();
    end

    for i = 1:map.size()
        value = map.get(java.lang.String(keys(i)));
        result.(keys{i}) = convert(value, convertToArray);
    end
end

function result = convertList(list, convertToArray)

    % Convert Java list to cell array.
    result = cell(list.size(), 1);
    for i = 1:list.size()
        result{i} = convert(list.get(i - 1), convertToArray);
    end

    if ~convertToArray
        return; end

    % Convert to non-cell array if possible
    if isempty(result)
        result = zeros(1, 0);
        return
    elseif ~elementsHaveEqualType(result) || ~elementsAreAllNonNull(result)
        return
    elseif isstruct(result{1}) && ~structsAreCompatible(result)
        return
    elseif isa(result{1}, "ana.type.dict")
        return
    elseif elementsHaveEqualSize(result)
        numDims = effectiveSize(result{1});

        % Since we are working our way "inside-out", i.e. from the last
        % dimension to the first dimension, we need to concatenate
        % along a "new first dimension" before the current first
        % dimension. This is done by first concatenating along a new
        % dimension behind the last dimension ...
        result = cat(numDims + 1, result{:});

        % ... and then swapping the new last dimension with the
        % first dimension.
        if numDims > 0
            result = permute(result, [numDims+1, 1 : numDims]);
        end
    end
end

function result = elementsAreAllNonNull(cell_)
    result = all(cellfun(@(x) max(size(x)) > 0, cell_));
end

function result = elementsHaveEqualType(cell_)
    type1 = class(cell_{1});
    result = all( ...
        cellfun(@(x) isequal(class(x), type1), cell_) ...
    );
end

function result = elementsHaveEqualSize(cell_)
    size1 = size(cell_{1});
    result = all( ...
        cellfun(@(x) isequal(size(x), size1), cell_) ...
    );
end

function result = structsAreCompatible(cell_)
    fields = sort(fieldnames(cell_{1}));
    result = all(cellfun(@(s) isequal(sort(fieldnames(s)), fields), cell_));
end

% SPDX-License-Identifier: MIT
% Author(s):
%   Martin Koch
%   Jürgen "George" Sawinski
%
%
% This implementation is based on MartinKoch123-yaml-1.6.0.0, adapted for use
% with ana, licensed under:
% 
% MIT License
% 
% Copyright (c) 2022 Martin Koch
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
