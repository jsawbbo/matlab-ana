classdef leaf < ana.config.node.base
    %ana.config.node.leaf      Representation of a value.
    %

    %% HELPER
    methods (Hidden, Access=protected)
        function save_(obj,fd,level)
            arguments
                obj
                fd (1,1) double
                level {mustBeScalarOrEmpty} = 0
            end

            assert(~isa(obj.PrivateData_, 'ana.config.node.base'));
            if isobject(obj.PrivateData_)
                value = string(obj.PrivateData_);
            else
                value = obj.PrivateData_;
            end
            s = strtrim(ana.file.yaml.dump(value));
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
        function initialize(obj)
            % meta = obj.PrivateScheme_.meta();
            % if ~isempty(meta)
            %     if isfield(meta,'default')
            %         value = [];
            %         if isstruct(meta.default)
            %             if isfield(meta.default, 'eval')
            %                 value = eval(meta.default.eval);
            %             else
            %                 FIXME()
            %             end
            %         else
            %             value = meta.default;
            %         end
            % 
            %         obj.PrivateData_ = value;
            %         obj.PrivateDataLast_ =value;                    
            %     end
            % end
        end

        function [valid,reason] = validate(obj,value)
            if isa(value,"ana.config.node.base")
                value = value.get();
            end

            valid = false;
            reason = "don't know";

            % msg = [];
            % sch = obj.PrivateScheme_;
            % switch (sch.type())
            %     case 'boolean'
            %         if ~islogical(value)
            %             msg = "not a boolean value";
            %         end
            % 
            %     case 'integral'
            %         if ~isinteger(value)
            %             if ~isnumeric(value) || (round(value) ~= value)
            %                 msg = "not an integral value";
            %             else
            %                 value = int64(value);
            %             end
            %         end
            % 
            %     case 'numeric'
            %         if ~isnumeric(value)
            %             msg = "not a numeric value";
            %         end
            % 
            %     case 'string'
            %         if ~ischar(value) && ~isstring(value)
            %             msg = "not a string";
            %         else
            %             value = string(value);
            %         end
            % 
            %     case 'date'
            %         FIXME()
            % 
            %     case 'path'
            %         if ischar(value) || isstring(value)
            %             value = ana.fs.path(value);
            %         elseif ~isa(value,'ana.fs.path')
            %             msg = "not a path";
            %         end
            % 
            %     case 'any' 
            %         % equivalent of "no scheme", nothing to be done
            % 
            %     case 'category'
            %         FIXME
            % 
            %     otherwise
            %         error("ANA:scheme:invalidArgument", "Unknown or invalid type in scheme: %s", sch.type());
            % end
            % 
            % if ~isempty(msg)
            %     msg = msg + ", found '" + class(value) + "'";
            % else
            %     meta = obj.PrivateScheme_.meta();
            %     if ~isempty(meta)
            %         % FIXME check limits, patterns, etc.
            %         warning("FIXME not implemented")
            %     end
            % end
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

            if nargin == 0
                obj.PrivateData_ = [];
                obj.PrivateDataLast_ = [];

                obj.init();
            elseif iscell(value)
                error("ANA:scheme:invalidType", "cannot assign a cell to a leaf");
            else
                [value,msg] = obj.validate(value);
                if ~isempty(msg)
                    error("ANA:runtime", msg)
                end

                obj.PrivateData_ = value;
                obj.PrivateDataLast_ = value;
            end
        end

        function res = get(obj,varargin)
            %GET    Get Matlab value.
            res = obj.PrivateData_;
        end       

        function set(obj,value)
            %SET    Set value.
            %
            [value,msg] = obj.validate(value);
            if ~isempty(msg)
                error("ANA:runtime", msg)
            end
            obj.PrivateData_ = value;
            obj.autosave();
        end
    end
end
