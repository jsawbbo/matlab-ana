classdef datetime 
    % ana.type.datetime - Wrapper for MATLAB datetime with ISO 8601 UTC handling
    %
    % This class wraps MATLAB's datetime but defaults to local time if no time-zone
    % is given. Also, within ANA, the default in- and output format is in the form of
    %
    %      YYYYMMDD'T'hhmmss.SSSSSSSSSZ
    %
    % Example:
    %   dt = ana.type.datetime('20260315T143022')  % local time
    %   dt = ana.type.datetime('20260315T143022Z') % UTC
    %   dt = ana.type.datetime('20260315T143022', Locale='America/New_York')
    
    %% PROPERTIES
    properties (Hidden,Access = private)
        Value    % MATLAB datetime (always stored in UTC for consistency)
    end

    properties(Dependent)
        Format
        TimeZone
        Year
        Month
        Day
        Hour
        Minute
        Second
    end

    methods
        function res = get.Format(obj)
            res = obj.Value.Format;
        end

        function obj = set.Format(obj,value)
            obj.Value.Format = value;
        end

        function res = get.TimeZone(obj)
            res = obj.Value.TimeZone;
        end

        function obj = set.TimeZone(obj,value)
            obj.Value.TimeZone = value;
        end

        function res = get.Year(obj)
            res = obj.Value.Year;
        end

        function obj = set.Year(obj,value)
            obj.Value.Year = value;
        end

        function res = get.Month(obj)
            res = obj.Value.Month;
        end

        function obj = set.Month(obj,value)
            obj.Value.Month = value;
        end

        function res = get.Day(obj)
            res = obj.Day.Format;
        end

        function obj = set.Day(obj,value)
            obj.Value.Day = value;
        end

        function res = get.Hour(obj)
            res = obj.Value.Hour;
        end

        function obj = set.Hour(obj,value)
            obj.Value.Hour = value;
        end

        function res = get.Minute(obj)
            res = obj.Value.Minute;
        end

        function obj = set.Minute(obj,value)
            obj.Value.Minute = value;
        end

        function res = get.Second(obj)
            res = obj.Value.Second;
        end

        function obj = set.Second(obj,value)
            obj.Value.Second = value;
        end
    end

    %% HELPER
    methods
        function disp(obj)
            disp(obj.Value)
        end

        function res = string(obj)
            res = string(obj.Value);
            %TODO
            %- should return "Z" instead of +0000 or +00:00 for UTC time-zone
        end
    end

    %% STATIC
    methods (Static)
        function res = timezone()
            %TIMEZONE   Get system time-zone.
            persistent systz
            if isempty(systz)
                systz = datetime().SystemTimeZone;
            end
            res = systz;
        end

        function res = now()
            %NOW    Get current time.
            res = ana.type.datetime();
        end
        
        function res = utcNow()
            %UTCNOW    Get current UTC time.
            res = ana.type.datetime(TimeZone='UTC');
        end
    end
    
    %% PUBLIC
    methods
        function obj = datetime(varargin,options)
            %DATETIME   Constructor
            %
            %   dt = ana.type.datetime()                    % current local time
            %   dt = ana.type.datetime(isoString)           % parse ISO 8601 
            %                                               % (default: 'YYYYMMDDTHHMMSS', fractional seconds and 
            %                                               %           time-zone optional)
            arguments(Repeating)
                varargin
            end

            arguments
                options.Format = "yyyyMMdd'T'HHmmss.SSSSSSSSSZ"
                options.Locale = feature('locale').time
                options.TimeZone = ana.type.datetime.timezone()
            end

            if isempty(varargin)
                obj.Value = datetime(datetime(),Format=options.Format,TimeZone=options.TimeZone,Locale=options.Locale);
            else
                try
                    obj.Value = datetime(varargin{:},InputFormat="yyyyMMdd'T'HHmmss.SSSSSSSSSz",Format=options.Format,TimeZone=options.TimeZone);
                catch me
                    try
                        obj.Value = datetime(varargin{:},InputFormat="yyyyMMdd'T'HHmmss.SSSSSSSSS",Format=options.Format,TimeZone=options.TimeZone);                    
                    catch me
                        obj.Value = datetime(varargin{:},TimeZone=options.TimeZone,Locale=options.Locale);
                        obj.Value.Format = options.Format;
                    end
                end
            end
        end
        
    end
    
end