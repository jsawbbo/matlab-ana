function [layers,raw] = load(filename)
    %ANA.FILE.SVG.LOAD Load an SVG file.
    %
    %   FIXME
    %
    arguments
        filename = []
    end

    % prepare and load XML data
    layers = [];
    raw = [];
    
    if isempty(filename)
        [file,location] = uigetfile('*.svg', 'Select SVG...');
        if isnumeric(file)
            return
        end
        filename = fullfile(location,file);
    end
    
    raw = ana.file.xml.load(filename);
end

