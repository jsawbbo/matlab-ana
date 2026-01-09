function [layers,raw] = load(filename)
    %ANA.FILE.SVG.LOAD Load an SVG file.
    %
    %   FIXME
    %
    arguments
        filename = []
    end

    layers = [];
    raw = ana.file.xml.load(filename);


end

