classdef shared < handle
    %ana.util.shared        Shared data object.
    %
    %   Generic shared data object (or handle, respectively).
    %
    %   The main purpose of this class is to facilitate global static
    %   class members (in terms of C++). 
    %
    %   Example:
    % 
    %       classdef MyClass
    %           properties (Constant)
    %               AppData = ana.util.shared
    %           end
    %       end
    %

    properties
        Data
    end

    methods
        function obj = shared(data)
            %SHARED     Construct an instance of this class
            if nargin > 0
                obj.Data = data;
            end
        end
    end
end