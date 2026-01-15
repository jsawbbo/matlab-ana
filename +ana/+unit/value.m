classdef value
    %ANA.UNIT.VALUE     Representation of a number with unit.
    %
    %   Detailed explanation goes here
    %

    properties
        Value = []      % Unit value
    end

    properties (Access=protected)
        L = 0
        
    end

    methods
        function obj = value()
            %VALUE Construct an instance of this class
            %   Detailed explanation goes here
        end
    end
end