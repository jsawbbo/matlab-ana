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
            try
                if obj.Autosave && obj.ismodified()
                    obj.save()
                end
            catch
                % FIXME why???
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

            obj@ana.config.node.dict();

            %%% check arguments
            % check/auto-fill "filename"
            if isempty(filename)
                configdir = ana.os.paths('configdir');
                filename = configdir / 'config.yml';
                if isempty(options.Scheme) || (strlength(options.Scheme) == 0)
                    options.Scheme = "general";
                end
            else
                filename = ana.fs.path(filename);
            end
            if isrelative(filename)
                filename = ana.fs.pwd() / filename;
            end

            obj.Path = filename;

            % auto-save option
            obj.Autosave = options.Autosave;

            % scheme
            if strlength(options.Scheme) > 0
                options.Scheme = ana.fs.path(options.Scheme);
            else
                options.Scheme = [];
            end
           
            %%% load config file, get version
            ver = "";
            if isfile(filename)
                cfg = ana.file.yaml.load(fullfile(filename));
                obj.set(cfg);
                ver = cfg.version;
            end

            %%% handle scheme (if applicable)
            if ~isempty(options.Scheme)
                sch = ana.config.scheme.load(options.Scheme);

                if isfile(filename)
                    % check version
                    if ~strcmp(ver, sch.version)
                        error("ANA:CONFIG:FILE:SCHEMEVER", "Scheme version mismatch: expected %s, got %s", sch.version, ver);
                    end

                    % validate
                    % FIXME assert(obj.validate(sch));
                else
                    obj.build(sch);
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

            fd = fopen(string(obj.Path),"w");
            if obj.hasscheme()
                fprintf(fd,"version: ""%s""\n",obj.Scheme.version);
            end
            obj.save_(fd,0);
            fclose(fd);
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski

