classdef file < ana.config.node.map
    %ana.config.file     Configuration file accessor class.
    %
    %   Detailed explanation goes here
    %

    properties (SetAccess=protected)
        Path
    end

    properties 
        Autosave = true
    end

    properties(SetAccess=private, Hidden)
        Data = struct();
    end
    
    methods(Hidden)
        function res = properties(obj)
            res = fieldnames(obj.Properties);
        end        

        function res = fieldnames(obj)
            res = fieldnames(obj.Properties);
        end

        function delete(obj)
            %DELETE Destructor.
            if obj.Autosave && obj.ismodified()
                obj.save()
            end
        end
    end

    methods(Hidden, Access=protected)
        function show(obj,level)
            arguments
                obj ana.config.file
                level {mustBeScalarOrEmpty} = 0
            end

            fprintf(" <a href=""matlab:help ana.config.file"">ana.config.file</a> with contents:\n")
            % FIXME Path,Autosave
            show@ana.config.node.map(obj,level+1);
            fprintf("\n")
        end
    end

    methods
        function set.Autosave(obj,value)
            arguments
                obj ana.config.file;
                value {mustBeNumericOrLogical}
            end

            if ~obj.Autosave && value
                obj.Autosave = true;
                if obj.ismodified()
                    obj.save()
                end
            else
                obj.Autosave = value;
            end
        end
    end

    methods
        function obj = file(filename,options)
            %file   Construct an instance of this class
            %
            arguments
                filename (1,:) = [];
                options.Autosave (1,1) logical = true;
                options.Scheme (1,1) string = '';
            end

            % options
            obj.Autosave = options.Autosave;
            if strlength(options.Scheme) > 0
                obj.Scheme = ana.fs.path(options.Scheme);
            else
                obj.Scheme = [];
            end

            % config file
            if isempty(filename)
                configdir = ana.os.paths('configdir');
                filename = configdir / 'config.yml';
            end

            obj.Path = ana.fs.path(filename);

            % load scheme
            if ~isempty(obj.Scheme)
                obj.Scheme = ana.config.scheme(obj.Scheme);
            end
            
            % load config file
            if isfile(filename)
                obj.set(ana.file.yaml.load(fullfile(filename)));
                if ~isempty(obj.Scheme)
                    % FIXME
                end
            end
        end

        function save(obj)
            %save       Save contents to file.
            arguments
                obj ana.config.file;
            end

            % FIXME
            % 
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski

