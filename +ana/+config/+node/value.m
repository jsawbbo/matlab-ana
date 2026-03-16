classdef value < ana.config.node.base
    %VALUE      Representation of a value.
    %
    %   Detailed explanation goes here
    
    %% class data
    properties (Access=protected)
        Value = []
        LastValue = []
    end
    
    %% internal
    methods (Hidden, Access=protected)
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

        function save_(obj,fd,level)
            arguments
                obj ana.config.node.value
                fd (1,1) double
                level {mustBeScalarOrEmpty} = 0
            end

            switch (class(obj.Value))
                case "string"
                    % FIXME multiline ? wrap ? need quotes?
                    fprintf(fd, " %s", obj.Value);
                otherwise
                    fprintf(fd, " %s", string(obj.Value));
            end
            % indent_s = strjoin(repmat(" ",1,4*level)); % FIXME number of spaces
            % key = keys(obj.Properties);
            % N = length(key);
            % for i = 1:N
            %     if (level > 0) && (i == 1)
            %         fprintf(fd,"\n");
            %     end
            %     fprintf(fd, "%s%s:", indent_s, key(i));
            % 
            %     try
            %         obj.lookup(key(i)).save_(fd,level+1);
            %     catch me
            %         disp(me)
            %     end
            % 
            %     if (i < N) || (level == 0)
            %         fprintf(fd, "\n");
            %     end
            % end
        end
    end

    %% scheme
    methods (Access = protected)
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

            if isfield(sch.meta,"default")
                if isstruct(sch.meta.default)
                    if isfield(sch.meta.default,"eval")
                        obj.Value = eval(sch.meta.default.eval);
                    else
                        FIXME
                    end
                else
                    obj.Value = sch.meta.default;
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
            switch (sch.type)
                case "logical"
                    if ~islogical(obj.Value)
                        error("ANA:CONFIG:NODE:VALUE:TYPE", "Invalid type for value ""%s"", expected logical value.", sch.key)
                    end
                    FIXME
                case "numeric"
                    if ~isnumeric(obj.Value)
                        error("ANA:CONFIG:NODE:VALUE:TYPE", "Invalid type for value ""%s"", expected numeric value.", sch.key)
                    end
                    if isfield(sch.meta,"min")
                        if obj.Value < sch.meta.min
                            warning("ANA:CONFIG:NODE:VALUE:MIN", "Value below minimum for ""%s""", sch.key)
                            obj.Value = sch.meta.min;
                        end
                        if obj.Value > sch.meta.max
                            warning("ANA:CONFIG:NODE:VALUE:MAX", "Value above maximum for ""%s""", sch.key)
                            obj.Value = sch.meta.max;
                        end
                    end
                case "string"
                    if ~isstring(obj.Value)
                        error("ANA:CONFIG:NODE:VALUE:TYPE", "Invalid type for value ""%s"", expected string value.", sch.key)
                    end
                    FIXME
                case "path"
                    FIXME
                case "category"
                    FIXME
                otherwise
                    FIXME
            end
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

            if iscell(value)
                obj.LastValue = obj.Value;
            else
                obj.Value = value;
                obj.LastValue = value;
                obj.validate();
            end
        end

        function res = ismodified(obj)
            arguments
                obj ana.config.node.value
            end

            res = ~isequal(obj.Value, obj.LastValue);
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
            % FIXME scheme type may be something else...
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

