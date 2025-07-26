classdef map < ana.config.base.node & matlab.mixin.indexing.RedefinesDot
    %MAP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Hidden,Access=protected)
        Properties = struct();          % Internal properties node.
    end
    
    methods (Access=protected)
        function n = dotListLength(obj,indexOp,indexContext)
            n = listLength(obj.Properties,indexOp,indexContext);
        end

        function varargout = dotReference(obj,indexOp)
            % FIXME access to value node should return value
            [varargout{1:nargout}] = obj.Properties.(indexOp);
        end

        function obj = dotAssign(obj,indexOp,varargin)
            % FIXME 
            % -differentiate between value and node assignment
            % -node assignment needs to propagate Parent,Scheme
            [obj.Properties.(indexOp)] = varargin{:};
        end
    end

    methods
        function obj = map(options)
            %MAP Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            poptions = namedargs2cell(options);
            obj@ana.config.base.node(poptions{:});
        end

        function res = fieldnames(obj)
            %FIELDNAMES Get map keys.
            res = fieldnames(obj.Properties);
        end

        
    end
end

