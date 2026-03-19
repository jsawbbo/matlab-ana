classdef common < handle
    %ana.config.node.common         Configuration node base class.
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
        function dump_(obj,fd,level)
            arguments
                obj (1,1) {mustBeA(obj,"ana.config.node.common")}
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
            obj.dump_(1,1);
            fprintf("\n")
        end
    end        

    methods (Access = protected)
        function value = make(obj,value)
            if ~isa(value,'ana.config.node.common')
                if obj.hasscheme()
                    FIXME
                else
                    value = ana.config.node.value(value,Parent=obj);
                end
            end
        end
    end

    %% SCHEME
    methods (Access = protected)
        function res = hasscheme(obj)
            %hasscheme      Check, if a scheme is present.
            arguments
                obj ana.config.node.common
            end
            res = ~isempty(obj.PrivateScheme_);
        end

        function res = select(obj,key)
            %select         Select scheme sub-node by key.
            arguments
                obj ana.config.node.common
                key string
            end
            res = [];

            if ~obj.hasscheme()
                return
            end

            cnt = obj.PrivateScheme_.content;
            for i = 1:length(cnt)
                if isequal(cnt(i).key, key)
                    res = cnt(i);
                    return
                end
            end
        end

        function build(obj,sch)
            %build          Build node from scheme.
            arguments
                obj ana.config.node.common
                sch = []
            end

            error("ana:internal:RequiresImplementation", "Internal error: function or method should but is not implemented.")
        end

        function validate(obj,sch,varargin)
            %check          Check node from scheme
            arguments
                obj ana.config.node.common
                sch = []
            end
            arguments (Repeating)
                varargin
            end

            error("ana:internal:RequiresImplementation", "Internal error: function or method should but is not implemented.")
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
            obj.PrivateScheme_ = options.Scheme;
            if isstruct(obj.PrivateScheme_)
                obj.build(obj.PrivateScheme_);
            end
        end

        function res = root(obj)
            %root   Find root node.
            %
            arguments
                obj ana.config.base.common
            end

            res = obj;
            while ~isempty(res.Parent)
                res = res.Parent;
            end
        end

        function res = ismodified(obj)
            %ismodified     Check if modified.
            %
            arguments
                obj ana.config.base.common
            end
            
            res = ~isequal(obj.PrivateData_,obj.PrivateDataLast_);
        end

        function apply(obj)
            %apply      Apply changes.
            arguments
                obj ana.config.node.common
            end
            
            obj.PrivateDataLast_ = obj.PrivateData_;
        end

        function reset(obj)
            %reset      Reset changes.
            arguments
                obj ana.config.node.common
            end

            obj.PrivateData_ = obj.PrivateDataLast_;
        end

        function dump(obj)
            %dump       Dump contents (YAML).
            obj.save_(1,0);
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
