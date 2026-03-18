classdef common < handle
    %ana.config.node.common         Configuration node base class.
    %
    %
    
    %% PROPERTIES
    properties (SetAccess=protected)
        Parent_ = [];                    % Parent node.
        Scheme_ = [];                    % Scheme node (if available).
    end

    properties (SetAccess=protected) % TODO make Hidden
        Value_ = [];                     % Current value.
        LastValue_ = [];                 % Last value (before change).
    end

    properties (Constant,Hidden)
        Indent_ = 4                      % Number of spaces for indentation.
    end

    %% HELPER
    methods
        function disp(obj)
            arguments
                obj ana.config.node.common
            end

            fprintf("  <a href=""%s"">%s</a> contains:\n", class(obj), class(obj));
            obj.save_(1,1);
            fprintf("\n")
        end
    end        

    methods (Hidden, Access=protected)
        function save_(obj,fd,level)
            error('internal error: not implemented')
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
            res = ~isempty(obj.Scheme_);
        end

        function res = select(obj,key)
            %select     Select scheme sub-node by key.
            arguments
                obj ana.config.node.common
                key string
            end
            res = [];

            if ~obj.hasscheme()
                return
            end

            cnt = obj.Scheme_.content;
            for i = 1:length(cnt)
                if isequal(cnt(i).key, key)
                    res = cnt(i);
                    return
                end
            end
        end

        function build(obj,sch)
            %build   Build node from scheme.
            arguments
                obj ana.config.node.common
                sch = []
            end
            error("internal error: implementation required")
        end

        function validate(obj,sch,varargin)
            %check  Check node from scheme
            arguments
                obj ana.config.node.common
                sch = []
            end
            arguments (Repeating)
                varargin
            end
            error("internal error: implementation required")
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

            obj.Parent_ = options.Parent;
            obj.Scheme_ = options.Scheme;
            if isstruct(obj.Scheme_)
                obj.build(obj.Scheme_);
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
            
            res = ~isequal(obj.Value_,obj.LastValue_);
        end

        function apply(obj)
            %apply      Apply changes.
            arguments
                obj ana.config.node.common
            end
            
            obj.LastValue_ = obj.Value_;
        end

        function reset(obj)
            %reset      Reset changes.
            arguments
                obj ana.config.node.common
            end

            obj.Value_ = obj.LastValue_;
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
