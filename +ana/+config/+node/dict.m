classdef dict < ana.config.node.base & matlab.mixin.indexing.RedefinesDot
    %ana.config.node.dict        Key-value pair map.
    %
    %   This class represents (in JSON jargon) a [key-value pair] map implemented
    %   around Matlab's 'dictionary' (it should be noted, that, especially for
    %   the purpose of use with GUIs, a 'dictionary' is sorted by order of first 
    %   time key insertion).
    %
    %   See also: ana.config.node.base
    
    %% class data
    properties(Access=protected)
        Properties = dictionary(string([]), {});    % Internal storage.
    end
        
    %% "RedefinesDot"
    methods
        function res = properties(obj)
            res = keys(obj.Properties);
        end        

        function res = fieldnames(obj)
            res = keys(obj.Properties);
        end
    end

    methods (Access = protected)
        function res = dotIndexOp(obj,scalarIndexOp)
            switch scalarIndexOp.Type
                case 'Dot'
                    res = obj.lookup(scalarIndexOp.Name);
                otherwise
                    error('internal error: expected dot operation')
            end
        end
    end

    methods (Access=protected)
        function n = dotListLength(obj,indexOp,indexContext)
            try
                n = listLength(obj.Properties,indexOp,indexContext);
            catch
                n = 1;
            end
        end

        function varargout = dotReference(obj,indexOp)
            tmp = obj;
            for i = 1:numel(indexOp)
                tmp = tmp.dotIndexOp(indexOp(i));
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
                                node = ana.config.node.dict(Parent=tmp); % FIXME Scheme
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
                key = indexOp(end).Name;
                value = varargin{1};
                if isa(value,'ana.config.node.value')
                    FIXME
                end

                switch indexOp(end).Type
                    case 'Dot'
                        if tmp.haskey(key)
                            tmp.lookup(key).set(value);
                        else
                            sch = [];
                            if ~isempty(tmp.Scheme)
                                sch = tmp.select(key);
                                if isempty(sch)
                                    warning("Insert a key (%s) for no scheme is present.", key)
                                end
                            end
                            tmp.insert(key, ...
                                ana.config.node.value(value,Parent=tmp,Scheme=sch));
                        end
                    otherwise
                        error('internal error: expected dot operation')
                end
            end
        end
    end

    %% internal
    methods(Hidden, Access=protected)
        function disp_(obj,level)
            arguments
                obj ana.config.node.dict
                level {mustBeScalarOrEmpty} = 0
            end

            if level == 0
                fprintf("  <a href=""matlab:help ana.config.node.dict"">ana.config.node.dict</a> with contents:\n")
                level = level + 1;
            end

            fn = keys(obj.Properties);
            for i = 1:numel(fn)
                key = fn{i};
                value = obj.Properties(key);
                fprintf("\n%s%s", pad('',level*4), key)
                disp_(value{1}, level+1);
            end
        end
    end
   
    %% scheme
    methods (Access = protected)
        function build(obj,sch)
            arguments
                obj ana.config.node.dict
                sch = []
            end

            if isempty(sch)
                sch = obj.Scheme;
                if isempty(sch)
                    return
                end
            end

            cnt = sch.content;
            for i = 1:length(cnt)
                switch (cnt(i).type)
                    case 'dict'
                        obj.insert(cnt(i).key, ...
                            ana.config.node.dict(Parent=obj,Scheme=cnt(i)));
                    case 'list'
                        obj.insert(cnt(i).key, ...
                            ana.config.node.list(Parent=obj,Scheme=cnt(i)));
                    case 'table'
                        obj.insert(cnt(i).key, ...
                            ana.config.node.table(Parent=obj,Scheme=cnt(i)));
                    otherwise
                        obj.insert(cnt(i).key, ...
                            ana.config.node.value(Parent=obj,Scheme=cnt(i)));
                end
            end
        end

        function res = validate(obj,sch)
            arguments
                obj ana.config.node.dict
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

    %% protected
    methods (Access=protected)
        function insert(obj,k,v)
            obj.Properties(k) = {v};
        end

        function res = lookup(obj,k)
            res = obj.Properties(k);
            res = res{1};
        end

        function res = haskey(obj,k)
            res = obj.Properties.isKey(k);
        end

        function set_(obj,key,value,scheme)
            arguments
                obj ana.config.node.dict
                key string
                value 
                scheme = []
            end

            if isstruct(value)
                dict = ana.config.node.dict(Parent=obj,Scheme=scheme);
                dict.set(value);
                obj.insert(key,dict);
            elseif iscell(value)
                list = ana.config.node.list(Parent=obj,Scheme=scheme);
                list.set(value);
                obj.insert(key,list);
            else
                obj.insert(key, ana.config.node.value(value,Parent=obj,Scheme=scheme));
            end
        end
    end

    %% public
    methods
        function obj = dict(options)
            %MAP Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            poptions = ana.util.passoptions(options, {'Parent','Scheme'});
            obj@ana.config.node.base(poptions{:});
        end

        function res = ismodified(obj)
            arguments
                obj ana.config.node.dict
            end
           
            res = false;
            f = fieldnames(obj);
            for k = 1:numel(f)
                node = obj.lookup(f{k});
                if node.ismodified()
                    res = true;
                    break;
                end
            end
        end

        function apply(obj)
            arguments
                obj ana.config.base.dict
            end

            f = fieldnames(obj);
            for k = 1:numel(f)
                obj.lookup(f{k}).apply();
            end
        end

        function reset(obj)
            arguments
                obj ana.config.base.dict
            end

            f = fieldnames(obj);
            for k = 1:numel(f)
                obj.lookup(f{k}).reset();
            end
        end
        
        function obj = set(obj,v,options)
            %set    FIXME
            arguments
                obj ana.config.node.dict
                v struct
                options.Key string = []
            end

            havescheme = ~isempty(obj.Scheme);
            subscheme = [];
            
            fn = fieldnames(v);
            for i = 1:numel(fn)
                key = string(fn{i});
                value = v.(key);

                % get subscheme
                if havescheme
                    subscheme = obj.Scheme.findkey(key);
                    if isempty(subscheme) 
                        % FIXME warning
                    end
                end

                obj.set_(key,value,subscheme);
            end
        end

        function res = get(obj)
            arguments
                obj ana.config.node.dict
            end

            res = struct();
            fn = keys(obj.Properties);
            for i = 1:numel(fn)
                key = fn{i};
                value = obj.lookup(key).get();
                res.(key) = value;
            end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski

