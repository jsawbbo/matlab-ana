classdef config < handle
    %ANA.CONFIG     Configuration file content with templating.
    %
    %   Detailed explanation goes here
    %

    properties(SetAccess=protected)
        Path
        Template = []
    end

    properties
        Autosave = true
    end

    properties(SetAccess=private,Hidden)
        Data = struct();
    end

    methods(Hidden)
        function varargout = subsref(self, S)
            switch S(1).type
                case '.'
                    % if isprop(self, S(1).subs) || ismethod(self, S(1).subs)
                    %     [varargout{1:nargout}] = builtin('subsref', self, S);
                    % else
                    %     try 
                    %         if ~self.Workspace.subsref(S).isUnassigned()
                    %             [varargout{1:nargout}] = self.Workspace.subsref(S);
                    %         else
                    %             [varargout{1:nargout}] = self.Global.subsref(S);
                    %         end
                    %     catch me %#ok<NASGU>
                    %         [varargout{1:nargout}] = self.Global.subsref(S);
                    %     end
                    % end
                    
                case '()'
                    % if (length(S) ~= 1) || (length(S(1).subs) ~= 1)
                    %     error('PAM:config:invalidIndex', 'Invalid index or reference.');
                    % end
                    % 
                    % if isempty(S(1).subs{1})
                    %     [varargout{1:nargout}] = self;
                    % else
                    %     [varargout{1:nargout}] = self.subsref(self.tosubs(S(1).subs{1}));
                    % end
                    
                otherwise
                    % error('ana:config:invalidIndex', 'Invalid index or reference.');
            end
        end
        
        function self = subasgn(self, S, value)
            switch S(1).type
                case '.'
                    % if isprop(self, S(1).subs) || ismethod(self, S(1).subs)
                    %     error('PAM:config:invalidAssignment', 'Invalid assignment');
                    % else
                    %     try 
                    %         self.Workspace = self.Workspace.subsasgn(S, value);
                    %     catch me %#ok<NASGU>
                    %         self.Global = self.Global.subsasgn(S, value);
                    %     end
                    % end
                    
                case '()'
                    % if (length(S) ~= 1) || (length(S(1).subs) ~= 1)
                    %     error('PAM:config:invalidIndex', 'Invalid index or reference.');
                    % end
                    % 
                    % self = self.subsasgn(self.tosubs(S(1).subs{1}), value);
                    
                otherwise
                    % error('ana:config:invalidIndex', 'Invalid index or reference.');
            end
        end
    end

    methods
        function obj = config(filename,options)
            %CONFIG Construct an instance of this class
            %
            %   Detailed explanation goes here
            %
            arguments
                filename (1,:) = [];
                options.Autosave {mustBeA(options.Autosave, 'logical')} = true;
                options.Template (1,1) string = '';
            end

            % options
            obj.Autosave = options.Autosave;
            obj.Template = options.Template;

            % config file
            if isempty(filename)
                configdir = ana.os.paths();
                filename = configdir / 'config.yaml';
            end

            if ~isa(filename, 'ana.fs.path')
                filename = ana.fs.path(filename);
            end

            [obj,loaded] = ana.tool.singleton.instantiate(obj,full(filename));
            if loaded
                return
            end

            % load template
            if strlength(options.Template) > 0
                % FIXME
            end

            % load config file
        end

        function delete(obj)
            %DELETE Destructor.
            % FIXME save?
        end
    end
end

