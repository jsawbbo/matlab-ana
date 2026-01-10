function xml = load(filename)
    %ANA.FILE.XML.LOAD  Load XML document and parse into a structure.
    %
    %   This function loads and XML file as outlined in 
    %   <a href='matlab:doc xmlread'>xmlread</a>.
    %   into a structure.
    %
    arguments
        filename = []
    end
    
    xml = [];

    if isempty(filename)
        [file,location] = uigetfile('*.xml', 'Select XML...');
        if isnumeric(file)
            return
        end
        filename = fullfile(location,file);
    end

    doc = xmlread(filename);
    xml = parseChildNodes(doc);
end

% The following code was adapted from 'doc xmlread'

function children = parseChildNodes(theNode)
    % Recurse over node children.
    children = [];
    if theNode.hasChildNodes
       childNodes = theNode.getChildNodes;
       numChildNodes = childNodes.getLength;
       allocCell = cell(1, 0);
    
       children = struct(             ...
          'Name', allocCell, 'Attributes', allocCell,    ...
          'Data', allocCell, 'Children', allocCell);
    
        for count = 1:numChildNodes
            theChild = childNodes.item(count-1);
            theStruct = makeStructFromNode(theChild);
            if ~isempty(theStruct)
                children(end+1) = theStruct; %#ok<AGROW>
            end
        end
    end
end

function nodeStruct = makeStructFromNode(theNode)
    % Create structure of node info.
    nodeStruct = [];
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

            nodeStruct = struct(  ...
               'Name', nodeName,  ...
               'Attributes', [],  ...
               'Data', text,      ...
               'Children', []);
        otherwise
            nodeStruct = struct(                        ...
               'Name', nodeName,                        ...
               'Attributes', parseAttributes(theNode),  ...
               'Data', [],                              ...
               'Children', parseChildNodes(theNode));
            
            if any(strcmp(methods(theNode), 'getData'))
               nodeStruct.Data = char(theNode.getData); 
            else
               nodeStruct.Data = '';
            end
    end
end

function attributes = parseAttributes(theNode)
    % Create attributes structure.
    
    attributes = [];
    if theNode.hasAttributes
       theAttributes = theNode.getAttributes;
       numAttributes = theAttributes.getLength;
       allocCell = cell(1, numAttributes);
       attributes = struct('Name', allocCell, 'Value', ...
                           allocCell);
    
       for count = 1:numAttributes
          attrib = theAttributes.item(count-1);
          attributes(count).Name = char(attrib.getName);
          attributes(count).Value = char(attrib.getValue);
       end
    end
end