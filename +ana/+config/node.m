classdef node < handle
    %ana.config.node    Configuration node base class.
    %
    %   A "configuration node" can be a simple branch node or represent a setting.
    %   These nodes may be accompanied by schemes. 
    %
    
    properties(Hidden)
        Parent = [];                    % Parent node.
    end

    properties(Hidden,SetAccess={?ana.config.node,?ana.config.scheme})
        Scheme = [];                    % Scheme node (if available).
    end

    % methods
    %     function set.Scheme(obj,scheme)
    %         arguments
    %             obj ana.config.node;
    %             scheme 
    %         end
    % 
    %         assignScheme(obj,scheme);
    %     end
    % 
    %     function assignScheme(obj,scheme)
    %         arguments
    %             obj ana.config.node;
    %             scheme 
    %         end
    % 
    %         if isempty(scheme)
    %             return
    %         end
    % 
    %         obj.Scheme = scheme;
    %         tr = scheme.Tree;
    % 
    %         if isa(obj, 'ana.config.node.map')
    %             if ~strcmp(tr.type,"map")
    %                 error("FIXME error in config file")
    %             end
    % 
    %             pn = properties(obj);
    % 
    %             for i = 1:length(tr.contents)
    %                 cnt = tr.contents(i);
    % 
    %                 switch cnt.type
    %                     case 'map'
    %                         if ~any(contains(string(pn), cnt.key))
    %                             obj.(cnt.key) = ana.config.node.map(Parent=obj,Scheme=cnt);
    %                         else
    %                             FIXME
    %                         end
    %                     otherwise
    %                         FIXME
    %                 end
    %             end            
    %         elseif isa(obj, 'ana.config.node.seq')
    %             FIXME
    %         elseif isa(obj, 'ana.config.node.value')
    %             FIXME
    %         else
    %             error("Internal error: invalid class")
    %         end
    %     end
    % end

    methods(Hidden)
        function disp(obj)
            arguments
                obj ana.config.node;
            end

            obj.disp_(0);
        end
    end        

    methods(Hidden, Access=protected)
        function disp_(obj,level) %#ok<INUSD>
            error('internal error: not implemented')
        end
    end

    methods (Access=protected)
        function res = wrap(obj, val)
            %wrap   Helper for assigning values.
            %
            %   An value must be encapsulated by a child class of ana.config.node.
            %   This functions helps to transform, for example, a bare value into
            %   a ana.config.node.value object.
            %

            if ~isa(val,'ana.config.node.value')
                res = val;
                return
            end

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
            if ~isempty(obj.Scheme)
                obj.Scheme.apply(obj);
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
% Author(s):
%   Jürgen "George" Sawinski
