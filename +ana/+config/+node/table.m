classdef table < ana.config.node.seq
    %ana.config.node.table      Table-like configuration node.
    %

    %% HELPER
    methods (Hidden, Access=protected)
    end

    %% SCHEME
    methods (Access = protected)
        function [res,msg] = validate(obj,sch,varargin)
            arguments
                obj 
                sch = []
            end
            arguments (Repeating)
                varargin
            end
            res = false;
            msg = "not supported";
        end        
    end
    
    %% PUBLIC
    methods
        function obj = table(options)
            %TABLE            Construct an instance of this class
            arguments
                options.Parent = [];
                options.Scheme = [];
            end

            obj@ana.config.node.seq(Parent=options.Parent,Scheme=options.Scheme);
        end
    end
end