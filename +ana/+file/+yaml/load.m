function result = load(filePath, options)
    %ANA.FILE.YAML.LOAD Read YAML file.
    %   DATA = ANA.FILE.YAML.LOAD(FILE) reads a YAML file and converts it to
    %   appropriate data types DATA.
    %
    %   DATA = ANA.FILE.YAML.LOAD(FILE, ConvertToArray=false) avoids conversion of
    %   sequences to 1D or 2D non-cell arrays.
    %
    %   The YAML types are convert to MATLAB types as follows:
    %
    %       YAML type                  | MATLAB type
    %       ---------------------------|------------
    %       Sequence                   | cell or array if possible and
    %                                  | "ConvertToArray" is enabled (default)
    %       Mapping                    | struct
    %       Floating-point number      | double
    %       Integer                    | double
    %       Boolean                    | logical
    %       String                     | string
    %       Date (yyyy-mm-ddTHH:MM:SS) | datetime
    %       Date (yyyy-mm-dd)          | datetime
    %       null                       | 0-by-0 double
    %
    %   Example:
    %       >> DATA.a = 1
    %       >> DATA.b = {"text", false}
    %       >> FILE = ".\test.yaml"
    %       >> ana.file.yaml.dump(FILE, DATA)
    %       >> ana.file.yaml.load("test.yaml")
    %
    %         struct with fields:
    %
    %           a: 1
    %           b: {["text"]  [0]}
    %
    %   See also ANA.FILE.YAML.DUMP, ANA.FILE.YAML.PARSE, ANA.FILE.YAML.SAVE
    
    arguments
        filePath (1, 1) string
        options.ConvertToArray (1, 1) logical = false
    end

    content = string(fileread(filePath));
    result = ana.file.yaml.parse(content, "ConvertToArray", options.ConvertToArray);

end
