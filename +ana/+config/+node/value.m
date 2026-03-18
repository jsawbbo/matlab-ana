classdef value < ana.config.node.common
    %ana.config.node.value      Representation of a value.
    %
    %   Detailed explanation goes here

    %% HELPER
    methods (Hidden, Access=protected)
        function save_(obj,fd,level)
            arguments
                obj ana.config.node.value
                fd (1,1) double
                level {mustBeScalarOrEmpty} = 0
            end

            assert(~isa(obj.Value_, 'ana.config.node.common'));
            s = strtrim(ana.file.yaml.dump(obj.Value_));
            lines = strsplit(s,"\n",CollapseDelimiters=false);
            if length(lines) > 1
                N = length(lines);
                switch (extract(s,1))
                    case "-"
                        indent_s = pad("", obj.Indent_*(level-1));
                        fprintf(fd,"\n");
                        for i = 1:N
                            fprintf(fd,"%s%s",indent_s,lines(i));
                            if i < N
                                fprintf(fd,"\n");
                            end
                        end
                    case {"|",">"}
                        indent_s = pad("", obj.Indent_*level);
                        fprintf(fd," %s\n", lines(1));
                        for i = 2:N
                            fprintf(fd,"%s%s",indent_s,strtrim(lines(i)));
                            if i < N
                                fprintf(fd,"\n");
                            end
                        end
                    otherwise
                        FIXME
                end
            else
                fprintf(fd, " %s", s);
            end
        end
    end

    %% PUBLIC
    methods
        function obj = value(value,options)
            arguments
                value  = {}
                options.Parent = [];
                options.Scheme = [];
            end

            obj@ana.config.node.common(Parent=options.Parent,Scheme=options.Scheme);

            if iscell(value)
                obj.LastValue_ = obj.Value_;
            else
                obj.Value_ = value;
                obj.LastValue_ = value;
            end
        end
    end
end