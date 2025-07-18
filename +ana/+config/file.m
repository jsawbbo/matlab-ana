classdef file < handle & matlab.mixin.indexing.RedefinesDot
    %ANA.CONFIG.FILE     Configuration file accessor class.
    %
    %   Detailed explanation goes here
    %

    properties(SetAccess=protected)
        Path
    end

    properties(SetAccess=private,Hidden)
        Scheme = []
        Autosave = true
        Data = struct();
    end

    methods (Access=protected)
        function varargout = dotReference(obj,indexOp)
            [varargout{1:nargout}] = obj.Data.(indexOp);
        end

        function obj = dotAssign(obj,indexOp,varargin)
            [obj.Data.(indexOp)] = varargin{:};
        end
        
        function n = dotListLength(obj,indexOp,indexContext)
            n = listLength(obj.Data,indexOp,indexContext);
        end
    end

    methods(Hidden)
        function names = properties(obj)
            names = fieldnames(obj.Data);
        end        

        function names = fieldnames(obj)
            names = fieldnames(obj.Data);
        end

        function delete(obj)
            %DELETE Destructor.
            % FIXME save
        end
    end

    methods
        function obj = file(filename,options)
            %FILE Construct an instance of this class
            %
            %   Detailed explanation goes here
            %
            arguments
                filename (1,:) = [];
                options.Autosave (1,1) logical = true;
                options.Scheme (1,1) string = '';
            end

            import ana.file.*

            % options
            obj.Autosave = options.Autosave;
            if strlength(options.Scheme) > 0
                obj.Scheme = ana.fs.path(options.Scheme);
            else
                obj.Scheme = [];
            end

            % config file
            if isempty(filename)
                configdir = ana.os.paths('configdir');
                filename = configdir / 'config.yaml';
            end

            if ~isa(filename, 'ana.fs.path')
                filename = ana.fs.path(filename);
            end
            obj.Path = filename;

            % load config file
            if isfile(filename)
                obj.Data = yaml.load(fullfile(filename));
                if isempty(obj.Data)
                    obj.Data = struct();
                end
            end

            % load and check scheme
            if ~isempty(obj.Scheme)
                obj.Scheme = ana.config.scheme(obj.Scheme);
                obj.Data = obj.Scheme.check(obj.Data);
            end
        end
    end
end

