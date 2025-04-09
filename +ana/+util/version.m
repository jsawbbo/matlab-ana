classdef version < matlab.mixin.Copyable
    %ANA.UTIL.VERSION Version information
    %

    properties(Constant,Hidden)
        matlab_ana = '0.0.0' % Current ANA version
    end
   
    properties (SetAccess = protected)
        Number = []         % Version array (major,minor,patch).
    end

    properties
        Tweak = []          % Tweak version (may be string, such as a git ID).
    end

    methods(Hidden)
        function parse(obj,s)
            arguments
                obj (1,1) ana.util.version;
                s (1,1) string;
            end

            p = strsplit(s, '.');
            n = numel(p);
            if (n < 1) || (n>4) 
                error('ana:util:version:format', 'invalid version format')
            elseif n < 2
                obj.Number = [str2double(p{1}), 0];
            else
                obj.Number = str2double(p);
            end

            if any(isnan(obj.Number))
                error('ana:util:version:format', 'invalid version format')
            end
        end

        function res = compare(a, b)
            b = ana.util.version(b);
            if numel(a.Number) < numel(b.Number)
                a = copy(a);
                while numel(a.Number) < numel(b.Number)
                    a.Number(end+1) = 0;
                end
            elseif numel(a.Number) > numel(b.Number)
                while numel(a.Number) > numel(b.Number)
                    b.Number(end+1) = 0;
                end
            end


            for i = 1:numel(a.Number)
                res = a.Number(i) - b.Number(i);
                if res ~= 0
                    break
                end
            end
        end
    end

    methods
        function obj = version(value)
            %VERSION Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                value = [];
            end

            if isempty(value)
                obj.parse(obj.ana);
            elseif isa(value,'ana.util.version')
                obj.Number = value.Number;
                obj.Tweak = value.Tweak;
            elseif isstring(value) || ischar(value)
                obj.parse(value);
            elseif isa(value,'double')
                n = numel(p);
                if (n < 1) || (n>4) 
                    error('ana:util:version:format', 'invalid version format')
                end
                obj.Number = value;
            else
                error('ana:util:version:parameter', 'parameter ''value'' must empty, string or version')
            end
        end

        function res = lt(obj,other)
            res = obj.compare(other) < 0;
        end

        function res = gt(obj,other)
            res = obj.compare(other) > 0;
        end

        function res = le(obj,other)
            res = obj.compare(other) <= 0;
        end

        function res = ge(obj,other)
            res = obj.compare(other) >= 0;
        end

        function res = ne(obj,other)
            res = obj.compare(other) ~= 0;
        end

        function res = eq(obj,other)
            res = obj.compare(other) == 0;
        end
    end
end

