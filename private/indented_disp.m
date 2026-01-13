function indented_disp(value,level,options)
    %RDISP Summary of this function goes here
    %   Detailed explanation goes here
    arguments
        value       % Value to display.
        level (1,1) double {mustBeInteger, mustBeNonnegative} = 1 % Display level
        options struct = struct() % Additional options for display
    end

    % FIXME

    disp(value)
end