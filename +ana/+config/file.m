classdef file < ana.config.object
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
        function obj = file(pathname,options)
            %file            Construct an instance of this class
            arguments
                pathname (1,:) = []
                options.Parent = []
                options.Scheme = []
            end

            if isempty(pathname)
                pathname = ana.os.paths('configdir') / "config.yml";
                options.Scheme = "/general";
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
        end

        function delete(~)
            %DELETE     Delete object.
            %
        end

        function save(obj)
            %SAVE   Save data to associated file.
            %
            if ~exist(+obj.PrivateFilename_,"file")
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
