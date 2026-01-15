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
    layers = extractLayers(raw(1));
end

function g = extractLayers(svg)
    assert(strcmp(svg.Name,'svg'), "not an SVG document");
    g = {};
    for i = 1:length(svg)
        if strcmp(svg(i).Name,'g')
            g{end+1} = convertLayer(svg(i));
        end
    end
end

function g = convertLayer(svg)
    g = svg;
end
