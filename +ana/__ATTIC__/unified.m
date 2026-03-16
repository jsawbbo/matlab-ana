classdef unified < handle & matlab.mixin.indexing.RedefinesDot
    %ana.config.unified     "Unified" configuration (ie. persistent and global).
    %
    %   This singleton class provides a mechanism to load configuration files
    %   in a hierarchical mannor, especially required when using a graphical
    %   user interface. Also, it avoids concurrent access to configuration files
    %   (this is restricted to a single Matlab instance).
    %
    %   FIXME
    %
    
    %% class data
    properties(Hidden,Access=protected)
        Config = {} 
    end
    
    %% "RedefinesDot"
    methods(Hidden)
        function res = properties(obj)
            FIXME
        end        

        function res = fieldnames(obj)
            FIXME
        end

        function delete(obj)
            %DELETE Destructor.
            if ~isempty(obj.Config)
                FIXME
            end
        end
    end

    methods(Hidden, Access=protected)
        function disp_(obj,level)
            arguments
                obj ana.config.node.map
                level {mustBeScalarOrEmpty} = 1
            end

            % fn = keys(obj.Properties);
            % for i = 1:numel(fn)
            %     key = fn{i};
            %     value = obj.Properties(key);
            %     fprintf("\n%s%s", pad('',level*4), key)
            %     disp_(value{1}, level+1);
            % end
        end
    end

    methods (Static, Access = protected)
        function res = dotIndexOp(dict,scalarIndexOp)
            switch scalarIndexOp.Type
                case 'Dot'
                    tmp = dict(scalarIndexOp.Name);
                    res = tmp{1};
                otherwise
                    error('internal error: expected dot operation')
            end
        end
    end

    methods (Access=protected)
        function n = dotListLength(obj,indexOp,indexContext)
            n = listLength(obj.Properties,indexOp,indexContext);
        end

        function varargout = dotReference(obj,indexOp)
            tmp = obj.dotIndexOp(obj.Properties,indexOp(1));
            if numel(indexOp) > 1
                for i = 2:numel(indexOp)
                    tmp = tmp.(indexOp(i));
                end
            end
            [varargout{1:nargout}] = tmp;
        end

        function obj = dotAssign(obj,indexOp,varargin)
            tmp = obj;
            if numel(indexOp) > 1
                assert(isscalar(varargin), 'internal error: expected single argument')

                for i = 1:numel(indexOp)-1
                    try
                        tmp = obj.dotIndexOp(tmp,indexOp(i));
                    catch
                        switch indexOp(i).Type
                            case 'Dot'
                                node = ana.config.node.map(Parent=tmp); % FIXME Scheme
                                tmp.Properties(indexOp(i).Name) = {node};
                                tmp = node;
                            otherwise
                                error('internal error: expected dot operation')
                        end
                    end
                end
            end

            if numel(varargin) > 1
                error('internal error: multiple assignments are not supported')
            else
                switch indexOp(end).Type
                    case 'Dot'
                        tmp.Properties(indexOp(end).Name) = {obj.wrap(varargin{1})};
                    otherwise
                        error('internal error: expected dot operation')
                end
            end
        end
    end

    %% methods:
    methods
        function obj = unified()
            %ALL    Construct a signleton of this class
            persistent singleton
            if isempty(singleton)
                singleton = obj;
            else
                obj = singleton;
            end
        end

        function add(obj,node)
            obj.Config{end+1} = node;
        end

        function res = ismodified(obj)
            %ISMODIFIED Check if modified.
            %
            arguments
                obj ana.config.node.map
            end

            FIXM
        end

        function apply(obj)
            %apply      Apply changes.
            arguments
                obj ana.config.base.node;
            end

            FIXME
        end

        function reset(obj)
            %reset      Reset changes.
            arguments
                obj ana.config.base.node;
            end

            FIXME
        end
        
        function set(obj, v)
            arguments
                obj ana.config.node.map
                v struct
            end

            FIXME
        end

        function res = get(obj)
            arguments
                obj ana.config.node.map
            end

            FIXME
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski

