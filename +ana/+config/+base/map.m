classdef map < ana.config.base.node & matlab.mixin.indexing.RedefinesDot
    %MAP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Hidden,Access=protected)
        Properties = struct();          % Internal properties node.
    end
    
    methods (Access=protected)
        function varargout = dotReference(obj,indexOp)
            [varargout{1:nargout}] = obj.Properties.(indexOp);
        end

        function obj = dotAssign(obj,indexOp,varargin)
            [obj.Properties.(indexOp)] = varargin{:};
        end
        
        function n = dotListLength(obj,indexOp,indexContext)
            n = listLength(obj.Properties,indexOp,indexContext);
        end
    end

    methods
        function obj = map(options)
            %MAP Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

