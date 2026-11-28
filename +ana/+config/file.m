classdef file < ana.config.branch
    %ana.config.file      Configuration file.
    %
    %   FIXME
    %

    %% PROPERTIES
    properties (SetAccess=protected)
        PrivateFilename_
    end

    %% PUBLIC
    methods
        function obj = file(path,options)
            %file            Construct an instance of this class
            %
            arguments
                path (1,:) = []         % File path or scheme index.
                options.Parent = []     % Parent branch.
                options.Scheme = []     % Scheme.
            end

            % singleton
            %TODO: implement singleton behavior (config is listed in ana.session)

            % check if index
            try 
                sch = ana.config.scheme(path);

                if sch.kind() ~= 'config'
                    error("ANA:Config:InvalidIndex", "Given index is not a configuration scheme.")
                end

                options.Scheme = sch;
                path = sch.config().file;
            catch
            end

            obj@ana.config.branch(Parent=options.Parent,Scheme=options.Scheme,Init=false);

            % initialize (delayed for singleton mechanism)
            obj.initialize()                     
            
            % load config file if it exists
            obj.PrivateFilename_ = ana.fs.path(path);

            if obj.PrivateFilename_.isalias()
                obj.PrivateFilename_ = obj.PrivateFilename_.resolve();
            end

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

                %TODO: check version

                obj.set(data);
            end
        end

        function delete(~)
            %DELETE     Delete object.
            %
        end

        function save(obj,options)
            %SAVE   Save data to associated file.
            %
            arguments
                obj ana.config.file
                options.Force logical = false
            end

            if ~exist(+obj.PrivateFilename_,"file")
                if ~options.Force
                    [partial,missing] = obj.ispartial();
                    if partial
                        msg = "Required fields in the configuration are missing:\n";
                        for k = 1:numel(missing)
                            msg = msg + sprintf("- %s\n", missing{k});
                        end
                        msg = msg + "File not saved.";
    
                        warning("ANA:runtime", msg);
                        return
                    end
                end
            else
                copyfile(+obj.PrivateFilename_, +obj.PrivateFilename_ + ".bak")
            end

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
