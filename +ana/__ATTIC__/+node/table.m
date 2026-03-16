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
            assert(isscalar(indexOp));
            switch (indexOp.Type)
                case 'Paren'
                    [varargout{1:nargout}] = table2cell(obj.Value(indexOp.Indices{:}));
                otherwise
                    error("invalid indexing operation")
            end
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

            s = table2struct(obj.Value);
            fn = fieldnames(s);
            fnlen = max(strlength(fn));
            indent_s = strjoin(repmat(" ", 1, 4*(level-1)),""); % FIXME number of spaces, also below

            N = size(s,1);
            for row = 1:N
                fprintf("\n%s-   %s: %s", indent_s, pad(fn{1},fnlen), string(s(row).(fn{1})));
                for i = 2:numel(fn)
                    fprintf("\n%s    %s: %s", indent_s, pad(fn{i},fnlen), string(s(row).(fn{i})));
                end
            end
        end

        function save_(obj,fd,level)
            arguments
                obj ana.config.node.table
                fd (1,1) double
                level {mustBeScalarOrEmpty} = 0
            end

            s = table2struct(obj.Value);
            fn = fieldnames(s);
           
            indent_s = strjoin(repmat(" ", 1, 4*(level-1)),""); % FIXME number of spaces
            N = size(obj.Value,1);

            if N > 0
                fprintf(fd,"\n%s",strjoin(repmat(" ", 1, 4*(level-2)),""));
            end                

            for row = 1:N
                for col = 1:length(fn)
                    if col == 1
                        c = '-';
                    else
                        c = '';
                    end

                    fprintf(fd, "%s%s%s: %s", indent_s, pad(c,4), fn{col}, string(obj.Value.(fn{col})(row)));

                    if col < length(fn)
                        fprintf(fd,"\n");
                    end
                end

                if row < N
                    fprintf(fd,"\n");
                end
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

            if isempty(v)
                obj.Value(:,:) = [];
                return
            end

            if isstruct(v)
                % FIXME check field names

                for i = 1:length(v)
                    row = struct2cell(v(i));
                    obj.add(row');
                end
            else
                FIXME
            end
        end

        function obj = add(obj,row)
            %add    Add a row.

            % FIXME validate
            obj.Value(end+1,:) = row;
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

