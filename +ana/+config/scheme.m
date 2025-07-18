classdef scheme < handle 
    %SCHEME Configuration scheme.
    %
    %   Detailed explanation goes here
    %
    
    properties(SetAccess=protected)
        Scheme
    end
    
    methods(Access=private,Hidden)
        function [node,type] = parseDefault(~,node)
            assert(isfield(node,'default'))

            type = [];
            if isstruct(node.default)
                if isfield(node.default, 'eval')
                    node.default = eval(node.default.eval);
                else
                    error('ana:config:scheme:default', 'invalid default field')
                end
            end

            if isstring(node.default) || ischar(node.default)
                type = 'string';
            elseif numel(node.default) > 1
                error("FIXME")
            else
                type = class(node.default);
            end
        end

        function node = parseNode(obj,node)
            if ~isfield(node,'type')
                % need to guess type from default
                [node,node.type] = obj.parseDefault(node);
                if isempty(node.type)
                    error('ana:config:scheme:type', 'type cannot be deduced, no default field')
                end
            end
            
            switch(node.type)
                case 'map'
                    for i = 1:numel(node.contents)
                        node.contents{i} = obj.parseNode(node.contents{i});
                    end
                    return
                case 'seq'
                    node.contents = obj.parseNode(node.contents);
                    return
                otherwise
                    if isfield(node,'default')
                        node = obj.parseDefault(node);
                    end
            end
        end

        function s = assignDefaults(obj,s,node)
            assert(isfield(node,'type'), 'internal error: node.type must be assigned')

            switch(node.type)
                case 'map'
                    if ~isfield(s,node.key)
                        s.(node.key) = struct();
                    end

                    for i = 1:numel(node.contents)
                        s.(node.key) = obj.assignDefaults(s.(node.key),node.contents{i});
                    end
                    return
                otherwise
                    if ~isfield(s,node.key) && isfield(node,'default')
                        s.(node.key) = node.default;
                    end
            end            
        end

        function checkEntry(obj,node,s,stack)
            assert(isfield(node,'type'), 'internal error: node.type must be assigned')

            switch(node.type)
                case 'map'
                    for i = 1:numel(node.contents)
                        if strcmp(node.contents{i}, stack{end})
                            % FIXME
                        end
                    end                   
            end
        end
    end

    methods
        function obj = scheme(name)
            %SCHEME   Construct scheme from file.
            %
            arguments
                name 
            end

            % load
            name = ana.fs.path(name);
            if name.isrelative()
                toolboxdir = ana.os.paths('toolboxdir');
                name = toolboxdir / 'scheme' / name + '.yaml';
            end

            if ~isfile(name)
                error('ana:config:scheme:no-such-file', 'scheme file does not exist');
            end

            obj.Scheme = ana.file.yaml.load(fullfile(name));
            obj.Scheme = obj.parseNode(obj.Scheme);
        end

        function s = check(obj, s)
            %CHECK Check a previously loaded configuration struct.
            %
            arguments
                obj ana.config.scheme
                s struct
            end

            % check version
            if isfield(s,'version')
                if ana.util.version(obj.Scheme.version) ~= s.version
                    error("FIXME")
                end
            else
                s.version = obj.Scheme.version;
            end

            % assign defaults
            contents = obj.Scheme.contents;
            for i = 1:numel(contents)
                s = obj.assignDefaults(s, contents{i});
            end
            
            % check existing entries
            fn = fieldnames(s);
            for i = 1:numel(fn)
                if strcmp(fn{i}, 'version')
                    continue
                end
                obj.checkEntry(obj.Scheme,s,{fn{i}}); %#ok<CCAT1>
            end
        end
    end
end

