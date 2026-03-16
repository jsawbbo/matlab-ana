classdef base < handle
    %ana.config.node.base    Configuration node base class.
    %
    %   Configuration node that abstracts Matlab 
    %   - cell arrays (ana.config.node.list), 
    %   - struct arrays (ana.config.node.table),
    %   - dictionaries (ana.config.node.dict), and,
    %   - values (ana.config.node.value).
    %   These plain Matlab types (read from a YAML config file, possibly supplemented
    %   by a scheme) are abstracted to support user-interfaces that provides a "Cancel"
    %   mechanism after entries were changed.
    %
    
    %% internal 
    properties
        Parent = [];                    % Parent node.
    end

    properties (SetAccess=protected)
        Scheme = [];                    % Scheme node (if available).
    end

    methods (Hidden)
        function disp(obj)
            arguments
                obj ana.config.node.base;
            end

            obj.disp_(0);
            fprintf("\n\n")
        end
    end        

    methods (Hidden, Access=protected)
        function disp_(obj,level) %#ok<INUSD>
            error('internal error: not implemented')
        end

        function save_(obj,fd,level)
            error('internal error: not implemented')
        end
    end

    %% scheme
    methods (Access = protected)
        function res = hasscheme(obj)
            %hasscheme      Check, if a scheme is present.
            arguments
                obj ana.config.node.base
            end
            res = ~isempty(obj.Scheme);
        end

        function res = select(obj,key)
            %select     Select scheme sub-node by key.
            arguments
                obj ana.config.node.base
                key string
            end
            res = [];

            if ~obj.hasscheme()
                return
            end

            cnt = obj.Scheme.content;
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
                obj
                sch = []
            end
            error("internal error: not implemented")
        end

        function validate(obj,sch)
            %check  Check node from scheme
            error("internal error: not implemented")
        end
    end

    %% public
    methods
        function obj = base(options)
            %base   Construct an instance of this class
            %
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            obj.Parent = options.Parent;
            obj.Scheme = options.Scheme;
            if isstruct(obj.Scheme)
                obj.build(obj.Scheme);
            end
        end

        function res = root(obj)
            %root   Find root node.
            %
            arguments
                obj ana.config.base.node;
            end

            res = obj;
            while ~isempty(res.Parent)
                res = res.Parent;
            end
        end

        function res = ismodified(obj) %#ok<*MANU>
            %ismodified     Check if modified.
            %
            arguments
                obj ana.config.base.node;
            end
            
            res = false;
        end

        function apply(obj)
            %apply      Apply changes.
            arguments
                obj ana.config.node.base;
            end
        end

        function reset(obj)
            %reset      Reset changes.
            arguments
                obj ana.config.node.base;
            end
        end

        function res = get(obj,varargin)
            %get    Get content (YAML conforming)
            error('internal error: not implemented')
        end

        function set(obj,value,varargin)
            %set    Set content (YAML conforming)
            error('internal error: not implemented')
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
