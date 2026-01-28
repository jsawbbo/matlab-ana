classdef base
    %ana.phys.unit.base         Unit base.
    %
    %   Detailed explanation goes here
    %

    properties (Constant,Hidden)
        Time = 1            % Time (s).
        Length = 2          % Length (m).
        Mass = 3            % Mass (kg).
        Current = 4         % Electric current (A).
        Temperature = 5     % Temperature (K).
        Amount = 6          % Amount of substance (mol).
        Intensity = 7       % Luminous intensity (Cd).

        Base_ = dictionary(...
                {"s","m","g","A","K","mol","Cd"},...
                {[ 1  0  0  0  0  0  0],...
                 [ 0  1  0  0  0  0  0],...
                 [ 0  0  1  0  0  0  0],...
                 [ 0  0  0  1  0  0  0],...
                 [ 0  0  0  0  1  0  0],...
                 [ 0  0  0  0  0  1  0],...
                 [ 0  0  0  0  0  0  1]}...
            )

        % rad = [ 0  0  0  0  0  0  0]
        % sr =  [ 0  0  0  0  0  0  0]
        % Hz =  [-1  0  0  0  0  0  0]
        % N =   [-2  1  1  0  0  0  0]
        % Pa =  [-2 -1  1  0  0  0  0]
        % J	    energy, work, amount of heat	kg⋅m2⋅s−2	
        % W	    power, radiant flux	kg⋅m2⋅s−3
        % C	    electric charge	s⋅A
        % V	    electric potential difference[a]	kg⋅m2⋅s−3⋅A−1	
        % Ω	    electrical resistance	kg⋅m2⋅s−3⋅A−2
        % S	    electrical conductance	kg−1⋅m−2⋅s3⋅A2	
        % F	    capacitance	kg−1⋅m−2⋅s4⋅A2
        % H	    inductance	kg⋅m2⋅s−2⋅A−2
        % T	    magnetic flux density	kg⋅s−2⋅A−1	
        % Wb	magnetic flux	kg⋅m2⋅s−2⋅A−1
        % °C	Celsius temperature	K
        % lm	luminous flux	cd⋅sr
        % lx	illuminance	cd⋅sr⋅m−2
        % Bq	activity referred to a radionuclide	s−1
        % Gy	absorbed dose, kerma	m2⋅s−2
        % Sv	dose equivalent	m2⋅s−2
        % kat	catalytic activity	mol⋅s−1

        config = ana.util.shared(struct(...  
                Unicode = false...              % Use Unicode for display purposes.
            ))             
    end

    properties
        
    end

    methods
        function obj = base(unit)
            %BASE   Construct an instance of this class
            arguments
                unit = []
            end

            if ~isempty(unit)
                FIXME
            end
        end
    end
end