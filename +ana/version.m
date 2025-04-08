function res = version(what)
    %ANA.VERSION    Get matlab-ana version info.
    %
    %Syntax:
    %   ans = ana.version()
    %
    %       Get software version ("<major>.<minor>").
    %
    %   ans = ana.version('full')
    %
    %       Get software release ("<major>.<minor>.<patch>").
    %
    %   ans = ana.version('number')
    %
    %       Get version as double.
    %
    %
    arguments
        what (1,1) string = '';
    end

    RELEASE = '0.0.0';

    switch(what)
        case 'number'
            m = regexp(RELEASE,'^[0-9]+[.][0-9]+','match');
            res = str2double(m);
        case 'full'
            res = RELEASE;
        otherwise
            res = regexp(RELEASE,'^[0-9]+[.][0-9]+','match');
            res = res{1};
    end
end

