classdef list < ana.config.node.base & matlab.mixin.indexing.RedefinesParen
    %ana.config.node.list       Representation of a cell array.
    %
    %   Detailed explanation goes here
    
    %% class data    
    properties(Access=protected)
        Properties = {};          % Internal properties node.
    end

    %% "RedefinesParen"
    methods (Static, Hidden)
        function obj = empty()
            obj = ana.config.node.list();
        end
    end

    methods (Hidden)
        function res = cat(dim,varargin)
            FIXME
        end

        function res = size(obj,varargin)
            res = numel(obj.Properties);
        end
    end

    methods(Hidden, Access=protected)
        function disp_(obj,level)
            arguments
                obj ana.config.node.list
                level {mustBeScalarOrEmpty} = 1
            end

            for key = 1:numel(obj.Properties)
                fprintf("\n%s-", pad('',(level-1)*4))
                disp_(obj.Properties{key}, level+1);
            end
        end        
    end

    methods (Access=protected)
        function varargout = parenReference(obj, indexOp)
            tmp = obj.Properties.(indexOp(1:end));
            [varargout{1:nargout}] = tmp{1};
        end

        function obj = parenAssign(obj,indexOp,varargin)
            % Ensure object instance is the first argument of call.
            FIXME()
            % if isempty(obj)
            %     obj = varargin{1};
            % end
            % if isscalar(indexOp)
            %     assert(nargin==3);
            %     rhs = varargin{1};
            %     obj.ContainedArray.(indexOp) = rhs.ContainedArray;
            %     return;
            % end
            % [obj.Properties.(indexOp(2:end))] = varargin{:};
        end

        function n = parenListLength(obj,indexOp,ctx)
            containedObj = obj.Properties.(indexOp(1));
            n = listLength(containedObj{:},indexOp(2),ctx);
        end

        function obj = parenDelete(obj,indexOp)
            FIXME
        end
    end    

    %% scheme
    methods(Hidden)
        function build(obj,sch)
            arguments
                obj ana.config.node.list
                sch = []
            end

            if isempty(sch)
                sch = obj.Scheme;
                if isempty(sch)
                    return
                end
            end

            FIXME
        end

        function res = validate(obj,sch)
            arguments
                obj ana.config.node.list
                sch = []
            end

            if isempty(sch)
                if isempty(obj.Scheme)
                    res = true;
                    return
                end
                sch = obj.Scheme;
            end

            res = false;
            FIXME
        end
    end
    
    %% public
    methods
        function obj = list(options)
            %seq    Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            poptions = ana.util.passoptions(options, {'Parent','Scheme'});
            obj@ana.config.node.base(poptions{:});
        end

        function res = ismodified(obj)
            arguments
                obj ana.config.node.list
            end
           
            res = false;
            for key = 1:numel(obj.Properties)
                if obj.Properties{key}.ismodified()
                    res = true;
                    return
                end
            end
        end

        function apply(obj)
            arguments
                obj ana.config.node.list
            end

            for key = 1:numel(obj.Properties)
                obj.Properties{key}.apply();
            end
        end

        function reset(obj)
            arguments
                obj ana.config.node.list
            end

            for key = 1:numel(obj.Properties)
                obj.Properties{key}.reset();
            end
        end
        
        function set(obj, s)
            arguments
                obj ana.config.node.list
                s cell
            end

            havescheme = ~isempty(obj.Scheme);
            subscheme = [];
            for key = 1:numel(s)
                value = s{key};

                if havescheme
                    % FIXME
                    subscheme = [];
                end

                if isstruct(value)
                    if havescheme
                        FIXME()
                    else
                        map = ana.config.node.dict(Parent=obj,Scheme=subscheme);
                        map.set(value);
                        obj.Properties{key} = map;
                    end
                elseif iscell(value)
                    if havescheme
                        FIXME()
                    else
                        list = ana.config.node.list(Parent=obj,Scheme=subscheme);
                        list.set(value);
                        obj.Properties{key} = list;
                    end
                else
                    obj.Properties{key} = ana.config.node.value(value,Parent=obj,Scheme=subscheme);
                end               
            end
        end

        function res = get(obj)
            arguments
                obj ana.config.node.list
            end

            N = numel(obj.Properties);
            res = cell(1,N);
            for key = 1:N
                value = obj.Properties{key}.get();
                res{key} = value;
            end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski

