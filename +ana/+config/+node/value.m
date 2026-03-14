classdef value < ana.config.node.base
    %VALUE      Representation of a value.
    %
    %   Detailed explanation goes here
    
    %% class data
    properties(Hidden, Access=protected)
        Value = []
        LastValue = []
    end
    
    %% internal
    methods(Hidden, Access=protected)
        function disp_(obj,level)
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

    %% scheme
    methods(Hidden)
        function build(obj,sch)
            arguments
                obj ana.config.node.value
                sch = []
            end

            if isempty(sch)
                sch = obj.Scheme;
                if isempty(sch)
                    return
                end
            end

            
        end

        function res = validate(obj,sch)
            arguments
                obj ana.config.node.value
                sch = []
            end

            if isempty(sch)
                if isempty(obj.Scheme)
                    res = true;
                    return
                end
                sch = obj.Scheme;
            end

            res = false;
            error("internal error: not implemented")
        end
    end
    
    %% public
    methods
        function obj = value(value,options)
            arguments
                value  = {}
                options.Parent = [];
                options.Scheme = [];
            end

            poptions = ana.util.passoptions(options, {'Parent','Scheme'});
            obj@ana.config.node.base(poptions{:});

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

