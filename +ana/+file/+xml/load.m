function res = load(filename)
    %ANA.FILE.XML.LOAD  Load XML document and parse into a structure.
    %
    %   This function loads and XML file as outlined in 
    %   <a href='matlab:doc xmlread'>xmlread</a>.
    %   into a structure.
    %
    arguments
        filename = []
    end
    
    res = [];

    if isempty(filename)
        [file,location] = uigetfile('*.xml', 'Select XML...');
        if isnumeric(file)
            return
        end
        filename = fullfile(location,file);
    end

    doc = xmlread(filename);
    res = ana.util.node(Name=filename,Children={});
    % FIXME res.Handler = ???
    res = parseChildNodes(doc, res);
end

% The following code was adapted from 'doc xmlread'

function node = parseChildNodes(xmlNode, node)
    % Recurse over node children.
    if xmlNode.hasChildNodes
        childNodes = xmlNode.getChildNodes;
        numChildNodes = childNodes.getLength;
    
        for count = 1:numChildNodes
            theChild = childNodes.item(count-1);
            theNode = makeNodeFromXML(theChild);
            if isobject(theNode)
                node(end+1) = theNode; %#ok<AGROW>
            end
        end
    end
end

function node = makeNodeFromXML(theNode)
    % Create structure of node info.
    node = [];
    nodeName = char(theNode.getNodeName);

    switch(nodeName)
        case '#comment'
            % ignoring comments
            return
        case '#text'
            % clean text, ignore if empty
            text = char(theNode.getData);
            text = regexprep(text, '\s+', ' ');
            text = strtrim(text);
            if isempty(text)
                return
            end

            node = ana.util.node(Name = nodeName,Data = text);
        otherwise
            
            if any(strcmp(methods(theNode), 'getData'))
                node = ana.util.node(                       ...
                    Name = nodeName,                        ...
                    Attributes = parseAttributes(theNode),  ...
                    Data = char(theNode.getData));
            else
                node = ana.util.node(                       ...
                    Name = nodeName,                        ...
                    Attributes = parseAttributes(theNode),  ...
                    Children={});

                node = parseChildNodes(theNode, node);
            end
    end
end

function attributes = parseAttributes(theNode)
    % Create attributes structure.
    
    attributes = [];
    if theNode.hasAttributes
        theAttributes = theNode.getAttributes;
        numAttributes = theAttributes.getLength;
        attributes = dictionary();
    
        for count = 1:numAttributes
            attrib = theAttributes.item(count-1);
            attributes(char(attrib.getName)) = char(attrib.getValue);
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
