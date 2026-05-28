classdef base < handle
    %ana.config.node.base               Configuration node base class.
    %
    
    %% PROPERTIES
    properties (SetAccess=protected)
        PrivateParent_ = [];            % Parent node.
        PrivateScheme_ = [];            % Scheme node (if available).
        PrivateType_ = [];              % Node or data type.
        PrivateData_ = [];              % Representation of encapsulated data.
        PrivateDataLast_ = [];          % As above, but, before "apply()" - may be unused.
    end

    %% INTERNAL
    methods (Hidden,Access = protected)
        function save_(obj,fd,level)
            arguments
                obj (1,1) 
                fd (1,1) double 
                level (1,1) {mustBeInteger,mustBeGreaterThan(level,-1)}
            end

            error("ANA:logic:requiresImplementation", "Internal error: function or method should but is not implemented.")
        end

        function autosave(obj)
            ptr = obj.root();
            if ptr ~= obj
                ptr.autosave();
            end
        end
    end

    %% HELPER
    methods
        function disp(obj)
            fprintf("  <a href=""%s"">%s</a> contents:\n", class(obj), class(obj));
            obj.save_(1,1);
            fprintf("\n")
        end
    end        

    %% SCHEME
    methods (Access = protected)
        function res = initialize(obj) %#ok<STOUT,MANU>
            %INIT   Initialize (if scheme is present)
            error("ANA:logic:requiresImplementation", "Internal error: method requires implementation.")
        end

        function [valid,reason] = validate(obj,item) %#ok<STOUT,INUSD>
            %VALIDATE   Validate an assignment.
            %
            %   This method shall return the validity of a set() operation, where
            %   the argument (`item`) depends on the node type.
            %
            %   On failure it also returns a reason for failure (as string).
            %
            error("ANA:logic:requiresImplementation", "Internal error: method requires implementation.")
        end        
    end

    %% PUBLIC
    methods
        function obj = base(options)
            %common   Construct an instance of this class
            %
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            obj.PrivateParent_ = options.Parent;
            obj.PrivateScheme_ = options.Scheme;
        end

        function res = root(obj)
            %ROOT   Find root node.
            %
            arguments
                obj 
            end

            res = obj;
            while ~isempty(res.PrivateParent_)
                res = res.PrivateParent_;
            end
        end

        function res = ismodified(obj)
            %ISMODIFIED     Check if modified.
            %
            arguments
                obj 
            end
            
            res = ~isequal(obj.PrivateData_,obj.PrivateDataLast_);
        end

        function apply(obj)
            %APPLY      Apply changes.
            arguments
                obj
            end
            
            obj.PrivateDataLast_ = obj.PrivateData_;
        end

        function reset(obj)
            %RESET      Reset changes.
            arguments
                obj 
            end

            obj.PrivateData_ = obj.PrivateDataLast_;
        end

        function dump(obj)
            %DUMP       Dump contents (YAML).
            obj.save_(1,0);
        end

        function res = get(obj)
            %GET    Get configuration as Matlab values.
            error("ANA:logic:requiresImplementation", "Internal error: function or method should but is not implemented.")
        end

        function set(obj,varargin)
            %SET    Set entries.
            error("ANA:logic:requiresImplementation", "Internal error: function or method should but is not implemented.")
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
