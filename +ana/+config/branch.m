classdef branch < handle
    %ana.config.branch      Configuration branch.
    %
    %   Configuration branches define the configuration tree in a hierarchical way.
    %

    %TODO 
    %- should not be a child of "ana.config.node.dict" because the semantics are different:
    %  here, we list branches of branches: if it's a config file, the lookup would be,
    %  for example obj.storage.storage (see also ana.session: obj.Config.ana.storage = storage;)
    %- validation needs to be based on the scheme hierarchy

    %% PROPERTIES
    properties(SetAccess = protected)
        Index                           % Branch index (local part only).

        PrivateParent_ = [];            % Parent node.
        PrivateScheme_ = [];            % Scheme node (if available).
        PrivateData_ = [];              % Representation of encapsulated data.
    end

    %% SCHEME
    methods (Access = protected)
    end
    
    %% UTILS
    methods (Access = protected)
    end

    %% PUBLIC
    methods
        function obj = branch(options)
            %branch            Construct an instance of this class
            arguments
                options.Parent = []
                options.Scheme = []
            end

            % FIXME
        end

        function res = index(obj)
            %INDEX      Get current index (including parents) as array.
            %

            if isempty(obj.PrivateParent_)
                res = obj.Index;
            else
                res = [obj.PrivateParent_.index(), obj.Index];
            end
        end
    end

    %% RedefinesParen
    methods (Access=protected)
    end

    %% RedefinesDot
    methods(Access=protected)
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
