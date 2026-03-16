classdef table < ana.config.node.base & matlab.mixin.indexing.RedefinesParen
    %ana.config.node.table       Representation of a table.
    %
    %   Detailed explanation goes here
    
    %% class data    
    properties (Access=protected)
        Value = []                  % The internal table.
        LastValue = []              % Unmodified table.

        VariableSchemes = []
    end

    %% "RedefinesParen"
    methods (Static)
        function obj = empty()
            obj = ana.config.node.table();
        end
    end

    methods 
        function res = cat(dim,varargin)
            FIXME
        end

        function varargout = size(obj,varargin)
           [varargout{1:nargout}] = size(obj.Value);
        end
    end

    methods (Access=protected)
        function varargout = parenReference(obj, indexOp)
            tmp = obj.Value.(indexOp(1:end));
            [varargout{1:nargout}] = tmp{1};
        end

        function obj = parenAssign(obj,indexOp,varargin)
            % Ensure object instance is the first argument of call.
            FIXME
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
            containedObj = obj.Value.(indexOp(1));
            n = listLength(containedObj{:},indexOp(2),ctx);
        end

        function obj = parenDelete(obj,indexOp)
            FIXME
        end
    end    

    %% internal
    methods (Hidden, Access=protected)
        function disp_(obj,level)
            arguments
                obj ana.config.node.table
                level {mustBeScalarOrEmpty} = 1
            end

            for key = 1:numel(obj.Value)
                fprintf("\n%s-", pad('',(level-1)*4))
                disp_(obj.Value{key}, level+1);
            end
        end        
    end

    %% scheme
    methods (Access = protected)
        function build(obj,sch)
            arguments
                obj ana.config.node.table
                sch = []
            end

            if isempty(sch)
                sch = obj.Scheme;
                if isempty(sch)
                    return
                end
            end

            obj.VariableSchemes = sch.content;

            % create table
            keys = [sch.content(:).key];
            types = [sch.content(:).type];
            for i = 1:length(types)
                switch(types(i))
                    case "numeric"
                        types(i) = "double";
                    case "category"
                        types(i) = "categorical";
                    case "path"
                        types(i) = "string";
                    otherwise
                        error("UNKNOWN TYPE: %s", types(i))
                end
            end

            obj.Value = table(VariableNames=keys,VariableTypes=types,Size=[0 length(keys)]);

            % defaults
            if isfield(sch.meta,"default")
                FIXME
            end
        end

        function res = validate(obj,sch)
            arguments
                obj ana.config.node.table
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
        function obj = table(options)
            %seq    Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            poptions = ana.util.passoptions(options, {'Parent','Scheme'});
            obj@ana.config.node.base(poptions{:});

            if isempty(options.Scheme)
                obj.Value = table();
                obj.LastValue = table();
            end
        end

        function res = ismodified(obj)
            arguments
                obj ana.config.node.table
            end
           
            res = ~isequal(obj.Value, obj.LastValue);
        end

        function apply(obj)
            arguments
                obj ana.config.node.table
            end

            obj.LastValue = obj.Value;
        end

        function reset(obj)
            arguments
                obj ana.config.node.table
            end

            obj.Value = obj.LastValue;
        end
        
        function obj = set(obj,v,options)
            %set    Set table rows
            %
            %   FIXME
            arguments
                obj ana.config.node.table
                v 
                options.Row (1,1) {mustBeInteger} = -1
            end

            havescheme = ~isempty(obj.Scheme);

            



            FIXME
        end

        function res = get(obj)
            arguments
                obj ana.config.node.table
            end

            res = table2struct(obj.Value);
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski

