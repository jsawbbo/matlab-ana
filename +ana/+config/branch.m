classdef branch < ana.config.node.dict
    %ana.config.branch      Configuration branch.
    %
    %   Configuration branches are, in itself, separate configuration nodes 
    %   (usually files, see ana.config.file). They can appear in a hierarchical
    %   tree of configuration objects, but are treated independently.
    %

    %TODO 
    %- should not be a child of "ana.config.node.dict" because the semantics are different:
    %  here, we list branches of branches: if it's a config file, the lookup would be,
    %  for example obj.storage.storage (see also ana.session: obj.Config.ana.storage = storage;)
    %- validation needs to be based on the scheme hierarchy

    %% SCHEME
    methods (Access = protected)
        function initialize(obj)
            % FIXME handle version
            initialize@ana.config.node.dict(obj);
        end
    end
    
    %% SCHEME
    methods (Access = protected)
        function [valid,reason] = validate(obj,key)
            reason = [];
            valid = true;
        end        
    end

    %% PUBLIC
    methods
        function obj = branch(options)
            %object            Construct an instance of this class
            arguments
                options.Parent = []
                options.Scheme = []
                options.Init = true
            end

            obj@ana.config.node.dict(Parent=options.Parent,Scheme=options.Scheme);
            if options.Init
                obj.initialize()
            end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
