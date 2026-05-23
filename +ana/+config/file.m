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

    %% INTERFACE
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
            end

            % load scheme
            if ~isempty(options.Scheme)
                scheme = ana.fs.path(options.Scheme);
                assert(~scheme.isrelative())
                if ~scheme.isfile()
                    scheme(end) = scheme(end) + ".yml";
                    scheme = ana.os.paths('toolboxdir') / "scheme" / scheme(2:end);
                end
                options.Scheme = ana.file.yaml.load(+scheme);
            end
            
            obj@ana.config.object(Parent=options.Parent,Scheme=options.Scheme);

            % load config file if it exists
            obj.PrivateFilename_ = ana.fs.path(pathname);
            if obj.PrivateFilename_.isfile()
                % check, if we were loaded already


                data = ana.file.yaml.load(obj.PrivateFilename_);
                obj.set(data);
            end

            obj.PrivateAutosave_ = options.Autosave;            
        end

        % FIXME add delete for Autosave

        function save(obj)
            %save   Save data to associated file.
            %FIXME
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
