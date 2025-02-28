function save(filePath,data,style)
    %ANA.YAML.SAVE Write data to YAML file.
    %   ANA.YAML.SAVE(FILE, DATA) converts DATA to YAML and saves it in a new
    %   file FILE.
    %
    %   ANA.YAML.SAVE(FILE, DATA, STYLE) uses a specific output style.
    %   STYLE can be "auto" (default), "block" or "flow".
    %
    %   The following types are supported for DATA:
    %       MATLAB type          | YAML type
    %       ---------------------|----------------------
    %       vector cell array    | Sequence
    %       struct               | Mapping
    %       scalar single/double | Floating-point number
    %       scalar int8/../int64 | Integer
    %       scalar logical       | Boolean
    %       scalar string        | String
    %       char vector          | String
    %       any 0-by-0 value     | null
    %
    %   Example:
    %       >> DATA.a = 1
    %       >> DATA.b = {"text", false}
    %       >> FILE = ".\test.yaml"
    %       >> yaml.dumpFile(FILE, DATA)
    %       >> yaml.loadFile("test.yaml")
    %
    %         struct with fields:
    %
    %           a: 1
    %           b: {["text"]  [0]}
    %
    %   See also YAML.PARSE, YAML.PARSE, YAML.LOAD
    
    arguments
        filePath (1, 1) string
        data
        style {mustBeMember(style, ["flow", "block", "auto"])} = "auto"
    end
    
    % Create YAML string.
    yamlString = yaml.dump(data, style);
    
    % Create folder.
    folder = fileparts(filePath);
    if strlength(folder) > 1 && ~isfolder(folder)
        mkdir(folder);
    end
    
    % Write file.
    [fid, msg] = fopen(filePath, "wt");
    if fid == -1
        error(msg)
    end
    fprintf(fid, "%s", yamlString);
    fclose(fid);
end

