classdef scheme < handle 
    %SCHEME Configuration scheme.
    %
    %   Detailed explanation goes here
    %
    
    properties(SetAccess=protected)
        Scheme
    end
    
    methods(Access=private,Hidden)
        function node = parseScheme(obj,node)
            if isfield(node, 'type')
                switch(node.type)
                    case 'map'
                        for i = 1:numel(node.content)
                            node.content{i} = obj.parseScheme(node.content{i});
                        end
                        return
                    case 'seq'
                        error("FIXME")
                    otherwise
                        error("FIXME")
                end
            end

            if isfield(node, 'content') && isstruct(node.content)
                if isfield(node.content,'eval')
                    node.content = eval(node.content.eval);
                end
            end

            if isfield(node, 'content') && ~isfield(node, 'type')
                if isnumeric(node.content)
                    node.type = 'numeric';
                elseif isstring(node.content) || ischar(node.content)
                    node.type = 'string';
                elseif islogical(node.content)
                    node.type = 'logical';
                else
                    error('ana:config:scheme:invalid-type', 'unsupported data type')
                end
            end
        end

        function s = assignDefaults(obj,s,node)
            assert(isfield(node,'type'), 'internal error: node.type must be assigned')

            switch(node.type)
                case 'map'
                    for i = 1:numel(node.content)
                        s = obj.assignDefaults(s,node.content{i});
                    end
                    return
                case 'seq'
                    error("FIXME")
                otherwise
                    if ~isfield(s,node.key)
                        s.(node.key) = node.content;
                    end
            end            
        end

        function checkEntry(obj,node,s,stack)
            assert(isfield(node,'type'), 'internal error: node.type must be assigned')

            switch(node.type)
                case 'map'
                    for i = 1:numel(node.content)
                        if strcmp(node.content{i}, stack{end})
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
            obj.Scheme = obj.parseScheme(obj.Scheme);
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
            s = obj.assignDefaults(s, obj.Scheme);
            
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

