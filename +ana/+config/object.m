classdef object < ana.config.node.dict
    %ana.config.object      Configuration object.
    %
    %   Configuration objects are, in itself, separate configuration nodes 
    %   (usually files, see ana.config.file). They can appear in a hierarchical
    %   tree of configuration objects, but are treated independently.
    %

    %% SCHEME
    methods (Access = protected)
        function init(obj)
            % FIXME handle version
            init@ana.config.node.dict(obj);
        end

        function [res,msg] = validate(obj,value,key)
            if strcmp(key,"version")
                FIXME("must not be changed")
            else
                [res,msg] = validate@ana.config.node.dict(obj,value,key);
            end
        end        
    end
    
    %% PUBLIC
    methods
        function obj = object(options)
            %object            Construct an instance of this class
            arguments
                options.Parent = []
                options.Scheme = []
                options.Tag = [] % FIXME not implemented currently!
                options.Init = true
            end

            obj@ana.config.node.dict(Parent=options.Parent,Scheme=options.Scheme);
            if options.Init
                obj.init()
            end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
