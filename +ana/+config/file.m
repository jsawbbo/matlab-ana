classdef file < ana.config.object
    %ana.config.file      Configuration file.
    %
    %   FIXME
    %

    %% PROPERTIES
    properties (SetAccess=protected)
        PrivateFilename_
        PrivateAutosave_ = false;
    end

    %% INTERNAL
    methods (Hidden,Access = protected)
        function autosave(obj,force)
            arguments
                obj
                force = false
            end

            if force || (obj.PrivateAutosave_ && obj.ismodified())
                fd = fopen(+obj.PrivateFilename_,"w");
                
                if ~isempty(obj.PrivateScheme_)
                    fprintf(fd, "version: ""%s""\n\n", obj.PrivateScheme_.version);
                end

                obj.save_(fd);
                fclose(fd);
            end
        end
    end
    
    %% PUBLIC
    methods
        function obj = file(pathname,options)
            %file            Construct an instance of this class
            arguments
                pathname (1,:) = []
                options.Parent = []
                options.Scheme = []
                options.Autosave = false
            end

            if isempty(pathname)
                pathname = ana.os.paths('configdir') / "config.yml";
                options.Scheme = "/general";
                % options.Autosave = true;
            else
                pathname = ana.fs.path(pathname);
            end

            obj@ana.config.object(Parent=options.Parent,Scheme=options.Scheme,Init=false);

            % do not load twice
            % FIXME implement a singleton mechanism

            % initialize (delayed for singleton mechanism)
            obj.initialize()                     
            
            % load config file if it exists
            obj.PrivateFilename_ = ana.fs.path(pathname);
            if obj.PrivateFilename_.isfile()
                data = ana.file.yaml.load(obj.PrivateFilename_);

                if isstruct(data)
                    ver = data.version;
                    data = rmfield(data, "version");
                elseif isa(data,'ana.type.dict')
                    ver = data("version");
                    data = rmfield(data, "version");
                else
                    error("ANA:internal:unexpectedType", "internal error: unexpected type")
                end

                % TODO: check version

                obj.set(data);
            end

            obj.PrivateAutosave_ = options.Autosave;

            if ~obj.PrivateFilename_.isfile()
                obj.autosave(~isempty(options.Scheme));
            end
        end

        % FIXME add delete for Autosave

        function save(obj)
            %SAVE   Save data to associated file.
            copyfile(+obj.PrivateFilename_, +obj.PrivateFilename_ + ".bak")
            fd = fopen(+obj.PrivateFilename_,"w");

            % emit header
            fprintf(fd, "version: %s\n\n", obj.PrivateScheme_.version());

            % contents
            obj.save_(fd,Comment=true);
            fclose(fd);
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
