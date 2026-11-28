classdef (Abstract, HandleCompatible) dot < ...
        matlab.mixin.indexing.RedefinesDot & ...
        matlab.mixin.indexing.OverridesPublicDotMethodCall
    %ana.concept.dot        FIXME
    %
    %   undefined
    %

    methods (Abstract, Access = protected)
        value = dotGet(obj, name)
        obj = dotSet(obj, name, value)
        tf = dotHas(obj, name)
    end

    %% RedefinesDot
    methods(Access=protected)
        function varargout = dotReference(obj, indexOp)
            field = indexOp(1).Name;

            % method call
            if numel(indexOp) > 1 && ...
                    indexOp(2).Type == "Paren" 
                args = indexOp(2).Indices;

                try
                    if numel(indexOp) == 2
                        [varargout{1:nargout}] = feval(field, obj, args{:});
                    else
                        result = feval(field, obj, args{:});
                        [varargout{1:nargout}] = result.(indexOp(3:end));
                    end
                    return
                catch
                end
            end

            % regular indexing
            if obj.dotHas(field)
                retval = obj.dotGet(field);

                if numel(indexOp) > 1
                    retval = retval.(indexOp(2:end));
                end

                [varargout{1:nargout}] = retval;
            else
                error("ANA:Dot:NoSuchField", "No such field-name: '%s'.", field);
            end
        end

        function obj = dotAssign(obj, indexOp, varargin)
            field = indexOp(1).Name;
            value = varargin{1};

            if isscalar(indexOp)
                obj.dotSet(field,value);
            else
                node = obj.dotGet(field);
                node = node{1};
                node.(indexOp(2:end)) = value;
                obj.dotSet(field,node);
            end
        end

        function n = dotListLength(obj, indexOp, ~)
            field = indexOp(1).Name;
            if obj.dotHas(field)
                n = 1;
            else
                error("ANA:Dot:NoSuchField", "No such field-name: '%s'.", field);
            end
        end
    end
end