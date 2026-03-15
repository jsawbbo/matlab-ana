classdef file < ana.config.node.dict
    %ana.config.file     Configuration file.
    %
    %   FIXME
    %

    %% class data
    properties (SetAccess=protected)
        Path
    end

    properties 
        Autosave = true
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
    
    %% internal
    methods(Hidden)
        function delete(obj)
            if obj.Autosave && obj.ismodified()
                obj.save()
            end
        end
    end

    methods(Hidden, Access=protected)
        function disp_(obj,level)
            arguments
                obj ana.config.file
                level {mustBeScalarOrEmpty} = 0
            end

            fprintf(" <a href=""matlab:help ana.config.file"">ana.config.file</a> with contents:\n")
            fprintf(" Path: %s\n",string(obj.Path))
            fprintf(" AutoSave: %d\n",obj.Autosave)
            disp_@ana.config.node.dict(obj,level+1);
            fprintf("\n")
        end
    end

    %% public
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
                options.Scheme = ana.fs.path(options.Scheme);
            else
                options.Scheme = [];
            end

            % config file
            if isempty(filename)
                configdir = ana.os.paths('configdir');
                filename = configdir / 'config.yml';
                if isempty(options.Scheme) || (strlength(options.Scheme) == 0)
                    options.Scheme = "general";
                end
            end

            obj.Path = ana.fs.path(filename);
            
            % load config file
            ver = "";
            if isfile(filename)
                cfg = ana.file.yaml.load(fullfile(filename));
                obj.set(cfg);
                ver = cfg.version;
            end

            % load scheme
            if ~isempty(options.Scheme)
                sch = ana.config.scheme.load(options.Scheme);

                if ~isfile(filename)
                    obj.build(sch);
                else
                    % check version
                    if ~strcmp(ver, sch.version)
                        error("ANA:CONFIG:FILE:SCHEMEVER", "Scheme version mismatch: expected %s, got %s", sch.version, ver);
                    end

                    % validate
                    assert(obj.validate(sch));
                end

                obj.Scheme = sch;

                % unified config
                % u = ana.config.unified();
                % u.add ...
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

