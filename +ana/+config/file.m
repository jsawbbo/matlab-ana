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
        function autosave(obj)
            if obj.PrivateAutosave_
                error("ana:internal:RequiresImplementation", "Internal error: function or method should but is not implemented.")
            end
        end
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
            else
                pathname = ana.fs.path(pathname);
            end

            obj@ana.config.object(Parent=options.Parent,Scheme=options.Scheme,Init=false);

            % do not load twice
            % FIXME implement a singleton mechanism

            % initialize
            obj.init()                     
            
            % load config file if it exists
            obj.PrivateFilename_ = ana.fs.path(pathname);
            if obj.PrivateFilename_.isfile()
                data = ana.file.yaml.load(obj.PrivateFilename_);
                obj.set(data);
            end

            obj.PrivateAutosave_ = options.Autosave;            
        end

        % FIXME add delete for Autosave

        function save(obj)
            %SAVE   Save data to associated file.
            %FIXME
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
