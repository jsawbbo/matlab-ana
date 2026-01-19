classdef base
    %ana.phys.unit.base         Unit base.
    %
    %   Detailed explanation goes here
    %

    properties
        

        L = 0           % Length.
        M = 0           % Mass.
        T = 0           % Time.
        I = 0           % Current.
        K = 0           % Temperature.
        N = 0           % Particle count 
        Cd = 0          % 

        % meter, kilogram, second, ampere, kelvin, mole, candela
    end

    methods
        function obj = types()
            %TYPES Construct an instance of this class
            %   Detailed explanation goes here
        end
    end
end