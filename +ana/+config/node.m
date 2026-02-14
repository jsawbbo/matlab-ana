classdef node < handle
    %ana.config.node    Configuration node base class.
    %
    %   A "configuration node" can be a simple branch node or represent a setting.
    %   These nodes may be accompanied by schemes. 
    %
    
    properties(Hidden)
        Parent = [];                    % Parent node.
    end

    properties
        Scheme = [];                    % Scheme node (if available).
    end

    methods
        function set.Scheme(obj,scheme)
            arguments
                obj ana.config.node;
                scheme 
            end

            if isempty(scheme)
                return
            end

            % FIXME

        end
    end

    methods(Hidden)
        function disp(obj)
            arguments
                obj ana.config.node;
            end

            obj.show(0);
        end
    end        

    methods(Hidden, Access=protected)
        function show(obj,level) %#ok<INUSD>
            error('internal error: not implemented')
        end
    end

    methods (Access=protected)
        function res = wrap(obj, val)
            %wrap   FIXME

            assert(isempty(obj.Scheme), 'FIXME')

            if isa(val, 'ana.config.node')
                res = val;
            else
                res = ana.config.node.value(val, Parent=obj);
            end
        end
    end

    methods
        function obj = node(options)
            %node   Construct an instance of this class
            %
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            obj.Parent = options.Parent;
            obj.Scheme = options.Scheme;
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
                obj ana.config.node;
            end
        end

        function reset(obj)
            %reset      Reset changes.
            arguments
                obj ana.config.node;
            end
        end

        function res = get(obj)
            %get    Get content (YAML conforming).
            arguments
                obj ana.config.node.value
            end
            res = [];
        end

        function set(obj,v)
            %set    Set content (YAML conforming).
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
