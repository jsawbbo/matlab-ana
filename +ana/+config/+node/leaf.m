classdef leaf < ana.config.node.base
    %ana.config.node.leaf      Representation of a value.
    %
    %   Detailed explanation goes here

    %% HELPER
    methods (Hidden, Access=protected)
        function save_(obj,fd,level)
            arguments
                obj
                fd (1,1) double
                level {mustBeScalarOrEmpty} = 0
            end

            assert(~isa(obj.PrivateData_, 'ana.config.node.base'));
            s = strtrim(ana.file.yaml.dump(obj.PrivateData_));
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
    
    %% SCHEME
    methods (Access = protected)
        function init(obj)
        end

        function [value,msg] = validate(obj,value)
            sch = obj.PrivateScheme_.get(key);
            if isempty(sch)
                msg = sprintf("invalid key: %s", string(key));
                return
            end

            % FIXME
        end        
    end

    %% PUBLIC
    methods
        function obj = leaf(value,options)
            arguments
                value  = {}
                options.Parent = [];
                options.Scheme = [];
            end

            obj@ana.config.node.base(Parent=options.Parent,Scheme=options.Scheme);

            if iscell(value)
                FIXME
            else
                obj.PrivateData_ = value;
                obj.PrivateDataLast_ = value;
            end
        end

        function res = get(obj,varargin)
            res = obj.PrivateData_;
        end       

        function set(obj,value)
            [value,msg] = obj.validate(key, value);
            if ~isempty(msg)
                error(msg)
            end
            obj.PrivateData_ = value;
            obj.autosave();
        end
    end
end