classdef leaf < ana.config.node.base
    %ana.config.node.leaf      Representation of a value.
    %
    % See also: ana.config.node.base

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
                        error("ANA:logic:requiresImplementation", "internal error: unexpected YAML format")
                end
            else
                fprintf(fd, " %s", s);
            end
        end
    end
    
    %% SCHEME
    methods (Access = protected)
        function initialize(obj)
            obj.PrivateData_ = [];
            if ~isempty(obj.PrivateScheme_)
                if isfield(obj.PrivateScheme_, "meta")
                    meta = obj.PrivateScheme_.meta;
                    if isfield(meta,"default")
                        default = meta.default;

                        if isstruct(default)
                            if isfield(default,"eval")
                                default = eval(meta.default);
                            else
                                error("ANA:internal", "internal error: should not happend...")
                            end
                        end

                        obj.PrivateData_ = default;
                        obj.PrivateDataLast_ = default;
                    end
                end
            end
        end

        function [valid,reason] = validate(obj,value)
            if isa(value,"ana.config.node.base")
                value = value.get();
            end

            % check, if 'value' is an acceptable type
            T = ana.config.scheme.typeid(value);
            if isempty(T)
                valid = false;
                reason = "invalid value type";
                return;
            end
            
            % check, what can be assigned
            reason = [];
            if isempty(obj.PrivateType_)
                if ~strcmp(T,"*")
                    % fix type (if value type is not "*", ie. empty)
                    obj.PrivateType_ = T;
                end
                valid = true;
            else
                valid = strcmp("*", obj.PrivateType_); % may assign any type
                if ~valid
                    valid = strcmp(T, obj.PrivateType_); 
                    if ~valid
                        % value types may not change
                        if strcmp(T,"*")
                            % except "null"
                            valid = true;
                        else
                            reason = "data type cannot be changed";
                            return
                        end
                    end
                end
            end

            % additional checks in the scheme's meta struct
            if ~isempty(obj.PrivateScheme_)
                if isfield(obj.PrivateScheme_, "meta")
                    meta = obj.PrivateScheme_.meta;

                    switch (obj.PrivateScheme_.type)
                        case "category"
                            assert(isfield(meta,"categories"), "error in scheme, expected field meta.categories")

                            valid = false;
                            for k = 1:numel(meta.categories)
                                valid = strcmp(meta.categories(k).value, value);
                                if valid
                                    break
                                end
                            end

                            if ~valid
                                reason = "invalid category";
                            end
                        case {"integral","numeric"}
                            if isfield(meta,"limit")
                                if isfield(meta.limit, "min")
                                    if value < meta.limit.min
                                        valid = false;
                                    end
                                end

                                if isfield(meta.limit, "max")
                                    if value > meta.limit.max
                                        valid = false;
                                    end
                                end

                                if ~valid
                                    reason = "value out of bounds";
                                end
                            end
                        otherwise
                            % nothing to be done
                    end
                end
            end
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

                obj.initialize();
            elseif iscell(value)
                error("ANA:scheme:invalidType", "cannot assign a cell to a leaf");
            else
                [valid,reason] = obj.validate(value);
                if ~valid
                    error("ANA:runtime", reason)
                end

                obj.PrivateData_ = value;
                obj.PrivateDataLast_ = value;
            end
        end

        function res = get(obj,varargin)
            %GET    Get Matlab value.
            %
            % See also: ana.config.node.base.uplus
            res = obj.PrivateData_;
        end       

        function obj = set(obj,value)
            %SET    Set value.
            %

            switch(obj.PrivateType_)
                case 'datetime'
                    value = ana.type.datetime(value);
                otherwise
                    % all good
            end

            [valid,reason] = obj.validate(value);
            if ~valid
                error("ANA:runtime", reason)
            end
            obj.PrivateData_ = value;
            obj.autosave();
        end
    end
end
