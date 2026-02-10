classdef map < ana.config.node & matlab.mixin.indexing.RedefinesDot
    %ana.config.node.map        Key-value pair map.
    %
    %   This class represents (in JSON jargon) a [key-value pair] map implemented
    %   around Matlab's 'dictionary' (it should be noted, that, especially for
    %   the purpose of use with GUIs, a 'dictionary' is sorted by order of first 
    %   time key insertion).
    %
    %   FIXME
    %
    
    %% class data
    properties(Hidden,Access=protected)
        Properties = dictionary;        % Internal storage.
    end
    
    %% "RedefinesDot"
    methods(Hidden)
        function res = properties(obj)
            res = keys(obj.Properties);
        end        

        function res = fieldnames(obj)
            res = keys(obj.Properties);
        end
    end

    methods(Hidden, Access=protected)
        function show(obj,level)
            arguments
                obj ana.config.node.map
                level {mustBeScalarOrEmpty} = 1
            end

            fn = keys(obj.Properties);
            for i = 1:numel(fn)
                key = fn{i};
                value = obj.Properties(key);
                fprintf("\n%s%s", pad('',level*4), key)
                show(value{1}, level+1);
            end
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
        function obj = map(options)
            %MAP Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            poptions = ana.util.passoptions(options, {'Parent','Scheme'});
            obj@ana.config.node(poptions{:});
        end

        function res = ismodified(obj)
            %ISMODIFIED Check if modified.
            %
            arguments
                obj ana.config.node.map
            end
           
            res = false;
            f = fieldnames(obj);
            for k = 1:numel(f)
                if obj.Properties.(f{k}).ismodified()
                    res = true;
                    break;
                end
            end
        end

        function apply(obj)
            %apply      Apply changes.
            arguments
                obj ana.config.base.node;
            end
        end

        function reset(obj)
            %reset      Reset changes.
            arguments
                obj ana.config.base.node;
            end
        end
        
        function set(obj, v)
            arguments
                obj ana.config.node.map
                v struct
            end

            % fill map
            havescheme = ~isempty(obj.Scheme);
            subscheme = [];
            fn = fieldnames(v);
            for i = 1:numel(fn)
                key = fn{i};
                value = v.(key);

                if havescheme
                    % FIXME
                    subscheme = [];
                end

                if isstruct(value)
                    if havescheme
                        FIXME()
                    else
                        map = ana.config.node.map(Parent=obj,Scheme=subscheme);
                        map.set(value);
                        obj.Properties.(key) = map;
                    end
                elseif iscell(value)
                    if havescheme
                        FIXME()
                    else
                        seq = ana.config.node.seq(Parent=obj,Scheme=subscheme);
                        seq.set(value);
                        obj.Properties.(key) = seq;
                    end
                else
                    obj.Properties.(key) = ana.config.node.value(value,Parent=obj,Scheme=subscheme);
                end
            end

            % fill missing keys from scheme
            if havescheme
                FIXME()
            end
        end

        function res = get(obj)
            arguments
                obj ana.config.node.map
            end

            res = struct();
            fn = fieldnames(obj.Properties);
            for i = 1:numel(fn)
                key = fn{i};
                value = obj.Properties.(key).get();
                res.(key) = value;
            end
        end
    end
end

