classdef config < handle
    %ANA.CONFIG     Configuration file content with template.
    %
    %   Detailed explanation goes here
    %

    properties(SetAccess=protected)
        Path
        Template
    end

    properties
        Autosave = true
    end
    
    properties(SetAccess=private,Hidden)
        Data = struct();
    end

    methods(Static)
        function reset()
            %ANA.CONFIG.RESET   Reset global configuration to defaults.
            % [configdir,~,toolboxdir] = ana.os.paths;
            % ana.fileformat.yaml.tmpl(full(toolboxdir / 'default' / 'config.yaml'), full(configdir), Update=false);
        end

        function update()
            %ANA.CONFIG.UPDATE  Update global configuration (after version change).
            error("FIXME")
        end
    end

    methods
        function obj = config(filename,options)
            %CONFIG Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                filename (1,:) = [];
                options.Autosave = true;
            end

            % options
            obj.Autosave = options.Autosave;

            % config file
            if isempty(filename)
                configdir = ana.os.paths();
                filename = configdir / 'config.yaml';
            end

            if ~isa(filename, 'ana.fs.path')
                filename = ana.fs.path(filename);
            end

            if ~filename.isfile()
                % need to create default config
                ana.config.reset();
            end

            % load config
            % FIXME
        end

    end
end

