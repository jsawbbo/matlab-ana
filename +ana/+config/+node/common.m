classdef common < handle
    %         Configuration node base class.
    %
    %
    
    %% PROPERTIES
    properties (SetAccess=protected)
        PrivateParent_ = [];            % Parent node.
        PrivateScheme_ = [];            % Scheme node (if available).
        PrivateData_ = [];              % Representation of encapsulated data.
        PrivateDataLast_ = [];          % As above, but, before "apply()" - may be unused.
    end

    properties (Hidden,Constant)
        YAMLIndent_ = 4                 % Default YAML indentation.
    end

    %% INTERNAL
    methods (Hidden,Access = protected)
        function save_(obj,fd,level)
            arguments
                obj (1,1) 
                fd (1,1) double 
                level (1,1) {mustBeInteger,mustBeGreaterThan(level,-1)}
            end

            error("ana:internal:RequiresImplementation", "Internal error: function or method should but is not implemented.")
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

    methods (Access = protected)
        % function value = make(obj,value)
        %     if ~isa(value,'')
        %         if obj.hasscheme()
        %             FIXME
        %         else
        %             value = ana.config.node.value(value,Parent=obj);
        %         end
        %     end
        % end
    end

    %% SCHEME
    methods (Access = protected)
        function res = hasscheme(obj)
            %hasscheme      Check, if a scheme is present.
            arguments
                obj 
            end
            res = ~isempty(obj.PrivateScheme_);
        end

        function [res,msg] = validate(obj,sch,varargin)
            arguments
                obj 
                sch = []
            end
            arguments (Repeating)
                varargin
            end
            res = false;
            msg = "not supported";
        end        
    end

    %% PUBLIC
    methods
        function obj = common(options)
            %common   Construct an instance of this class
            %
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            obj.PrivateParent_ = options.Parent;
            if ~isempty(options.Scheme)
                obj.PrivateScheme_ = ana.config.scheme(options.Scheme);
            end
        end

        function res = root(obj)
            %root   Find root node.
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
            %ismodified     Check if modified.
            %
            arguments
                obj 
            end
            
            res = ~isequal(obj.PrivateData_,obj.PrivateDataLast_);
        end

        function apply(obj)
            %apply      Apply changes.
            arguments
                obj 
            end
            
            obj.PrivateDataLast_ = obj.PrivateData_;
        end

        function reset(obj)
            %reset      Reset changes.
            arguments
                obj 
            end

            obj.PrivateData_ = obj.PrivateDataLast_;
        end

        function dump(obj)
            %dump       Dump contents (YAML).
            obj.save_(1,0);
        end

        function res = get(obj,varargin)
            %get    Get configuration as Matlab values.
            error("ana:internal:RequiresImplementation", "Internal error: function or method should but is not implemented.")
        end

        function set(obj,varargin)
            %set    Set entries.
            error("ana:internal:RequiresImplementation", "Internal error: function or method should but is not implemented.")
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
