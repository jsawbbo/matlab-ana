classdef value < ana.config.node
    %VALUE      Representation of a value.
    %   Detailed explanation goes here
    
    properties(Hidden, Access=protected)
        Value = []
        LastValue = []
    end
    
    methods(Hidden, Access=protected)
        function show(obj,level)
            arguments
                obj ana.config.node.value
                level {mustBeScalarOrEmpty} = 0
            end

            if level == 0
                disp(obj.Value)
                return
            end

            fprintf(": ")
            if ischar(obj.Value) || isstring(obj.Value)
                fprintf("""%s""", string(obj.Value));
            else
                fprintf("%s", string(obj.Value));
            end
        end
    end

    methods
        function obj = value(value,options)
            arguments
                value  = []
                options.Parent = [];
                options.Scheme = [];
            end

            poptions = ana.util.passoptions(options, {'Parent','Scheme'});
            obj@ana.config.node(poptions{:});

            obj.Value = value;
            obj.LastValue = value;
        end

        function res = ismodified(obj)
            arguments
                obj ana.config.node.value
            end

            res = (obj.Value ~= obj.LastValue);
        end

        function reset(obj)
            arguments
                obj ana.config.node.value
            end
            obj.Value = obj.LastValue;
        end

        function apply(obj)
            arguments
                obj ana.config.node.value
            end
            obj.LastValue = obj.Value;
        end

        function res = get(obj)
            arguments
                obj ana.config.node.value
            end
            res = obj.Value;
        end

        function set(obj,v)
            arguments
                obj ana.config.node.value
                v
            end
            obj.Value = v;
            % FIXME check scheme
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski

