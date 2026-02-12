classdef scheme < handle 
    %ana.config.scheme Configuration scheme.
    %
    %   Detailed explanation goes here
    %
    
    properties(SetAccess=protected)
        Scheme
    end
    
    methods
        function obj = scheme(name)
            %SCHEME   Construct an instance of this class
            %
            arguments
                name 
            end

            % % load
            % name = ana.fs.path(name);
            % if name.isrelative()
            %     toolboxdir = ana.os.paths('toolboxdir');
            %     name = toolboxdir / 'scheme' / name + '.yml';
            % end
            % 
            % if ~isfile(name)
            %     error('ANA:CONFIG:SCHEME:NO_SUCH_FILE', 'scheme file does not exist');
            % end
            % 
            % obj.Scheme = ana.file.yaml.load(fullfile(name));
            % obj.Scheme = obj.parseNode(obj.Scheme);
        end
    end
end

