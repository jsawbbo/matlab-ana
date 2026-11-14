classdef session < handle
    %ana.session      Persistent storage and synchronization for analysis sessions.
    %
    %   The ANA.SESSION serves as persistent variable storage and synchronization during
    %   the life-time of registered applications.
    %
    %   Configuration
    %   =============
    %
    %   The session class serves as the central point for loading configurations.
    %
    %   Variables
    %   =========
    %   
    %   Variables can either be managed using the get(), set() and remove() methods, or, 
    %   alternatively through indexing. Example:
    %
    %       s = ana.session();
    %       s('MY_VAR') = 'My Value';
    %
    %   Default variables:
    %       s('USER') = getenv('USER');
    %       s('Interactive') = true;
    %
    %   Interactive controls whether ANA may prompt the user.
    %   When false, operations requiring user input must use an
    %   established policy or report that a decision is required.
    %
    %   Aliases
    %   =======
    %
    %   Aliases are set during initialization and as well. See ana.fs.alias for further
    %   information.
    % 
    %   Applications
    %   ============
    %
    %   Applications can be registered using the register() method. This method will
    %   install a listener for unregistering the object on its destruction. The 'session'
    %   is locked in memory (i.e. stored data is persistent even across 'clear all') as
    %   long, as weak references to applications are kept.
    %

    %% PROPERTIES
    properties
        Config ana.config.object            % Configuration tree.
    end

    properties(SetAccess=protected)
        Variables ana.type.dict             % Variables.
        Aliases ana.type.dict               % Aliases.
        Objects = {}                        % Registered objects.
    end

    properties(Hidden)
        LogLevel = ana.log.level.INFO       % Global log level.
        LogFile = []                        % Log file (see ana.log.message)
    end

    properties(Hidden,Access=private)
        Instance = false                    % Flag, only true for actual singleton instance.
    end

    %% STATIC
    methods(Static,Access=private)
        %SINGLETON     Create or retrieve singleton instance.
        %
        function obj = singleton(obj)
            persistent instance
            if isempty(instance)
                obj.Instance = true;
                instance = obj;

                % load general config
                %TODO: load all relevant configs
                obj.load();

                % fill standard aliases from general config
                storage = obj.Config.general.storage;
                searchpath = storage.searchpath;
                aliases = cell(1, numel(searchpath));

                for a = 1:numel(searchpath)
                    aliases{a} = ana.fs.path(searchpath(a).location.get(), ...
                        Category=searchpath(a).category.get());
                end

                obj.Aliases.("storage") = aliases;
                obj.Aliases.("scratch") = ana.fs.path(storage.scratch.get());
                obj.Aliases.("project") = [];

                % fill standard variables
                obj.set("USER", getenv("USER"));
                obj.set(Interactive=true);
            else
                obj = instance;
            end
        end

        function persist()
            %PERSIST    Make the instance not "clearable".
            %
            % See: ana.session.release
            %
            mlock
        end

        function release()
            %RELEASE    Make the instance "clearable".
            %
            % See: ana.session.persist
            %
            munlock('ana.session');
        end
    end

    %% PROTECTED
    methods(Access=protected)
        function delete(obj)
            %DELETE Delete this object.
            if obj.Instance
                %TODO we could save the UserData here, but that would also require 
                %     a "LoadRecent=true" in the constructor...
            end
        end
    end

    %% CONFIG
    methods
        function load(obj,key)
            %LOAD       Load configuration.
            %
            %   FIXME
            %
            arguments
                obj ana.session
                key (1,:) string = "general";
            end

            configdir = ana.os.paths('configdir');

            for k = 1:numel(key)
                if key(k) == "general"
                    cfg = ana.config.file(configdir/"general.yml", Scheme="/general");
                    obj.Config.("general") = cfg;
                else
                    %TODO load additional configs, might be of the form "plugin.device"
                end
            end
        end
    end

    %% VARIABLES
    methods
        function obj = session()
            %STATE      Construct a singleton instance of this class.
            %
            obj = ana.session.singleton(obj);
        end

        function obj = set(obj,varargin)
            %SET        Set global variables.
            %
            %       ana.session().set(<key>,<value>,...)
            %       ana.session().set(<key>=<value>,...)
            %
            % Set a single or multiple values by key.
            %
            arguments
                obj ana.session
            end
            arguments(Repeating)
                varargin
            end

            for k = 1:2:numel(varargin)
                key = varargin{k};
                value = varargin{k+1};
                obj.Variables(string(key)) = value;
            end
        end

        function obj = remove(obj,varargin)
            %REMOVE     Remove global variable.
            %
            %       ana.session().remove('<key>')
            %       ana.session().remove('<key1>','<key2>',...)
            %       ana.session().remove({'<key1>','<key2>',...})
            %   
            % Remove one or multiple entries by key.
            %
            arguments
                obj ana.session
            end
            arguments(Repeating)
                varargin
            end

            if nargin == 1
                return
            elseif nargin == 2
                if iscell(varargin{1})
                    args = varargin{1};
                else
                    args = varargin;
                end
            else
                args = varargin;
            end

            for k = 1:numel(args)
                key = string(args{k});
                obj.Variables = obj.Variables.remove(key);
            end
        end

        function res = get(obj,varargin)
            %GET        Get global variables.
            %
            %       ana.session().get()
            % 
            % Get a copy of all entries.
            %
            %       ana.session().get("<key>")
            %
            % Retrieve a single entry.
            %
            %       ana.session().get("<key1>","<key2>")
            %       ana.session().get({"<key1>","<key2>"})
            %
            % Retrieve a multiple entries.
            %
            arguments
                obj ana.session
            end
            arguments(Repeating)
                varargin
            end

            if nargin == 1
                res = obj.Variables;
                return
            elseif nargin == 2
                if iscell(varargin{1})
                    args = varargin{1};
                else
                    key = string(varargin{1});
                    if isfield(obj.Variables, key)
                        res = obj.Variables(key);
                    else
                        res = [];
                        warning("No such key in ana.session's UserData: '%s'", key);
                    end
                    return
                end
            else
                args = varargin;
            end

            res = ana.type.dict();
            for k = 1:numel(args)
                key = string(args{k});
                if isfield(obj.Variables, key)
                    res(key) = obj.Variables(key);
                else
                    res(key) = [];
                    warning("No such key in ana.session's UserData: '%s'", key);
                end
            end
        end
    end

    %% ALIASES
    methods
        function res = hasalias(obj, key)
            %HASALIAS       Check if alias is stored.
            %
            arguments
                obj ana.session
                key (1,1) string
            end

            res = isfield(obj.Aliases, key);
        end

        function setalias(obj, key, loc, cat)
            %SETALIAS       Set alias.
            %
            %   FIXME
            %  
            arguments
                obj ana.session
                key (1,1) string
                loc (1,1) string
                cat = []
            end

            obj.Aliases(key) = struct('location', loc, 'category', cat);
        end

        function [loc,cat] = getalias(obj,key)
            %GETALIAS       Get alias.
            %
            %   FIXME
            %  
            arguments
                obj ana.session
                key (1,1) string
            end
            if obj.hasalias(key)
                alias = obj.Aliases(key);
                loc = [alias.location];
                cat = [alias.category];
            else
                loc = [];
                cat = [];
            end
        end
    end

    %% OBJECT REGISTRY
    methods 
        function register(obj, h)
            %REGISTER       Register a handle with the "session".
            %
            if ~isa(h, 'handle')
                error('ana.session:InvalidHandle', 'Registered object must be a handle.');
            end
            obj.Objects{end+1} = matlab.lang.WeakReference(h);
            ana.session.persist();

            % sync() method
            if ismethod(h, 'sync')
                % Object supports sync()
            end

            % unregister automatically  
            addlistener(h, 'ObjectBeingDestroyed', ...
                @(src, ~) obj.unregister(src));
        end

        function unregister(obj, h)
            %UNREGISTER     Unregister a handle.
            idx = cellfun(@(x) x.Handle == h, obj.Objects);
            obj.Objects(idx) = [];
            if isempty(obj.Objects)
                ana.session.release();
            end
        end

        function sync(obj, source, args)
            %SYNC   Synchronize data among registered applications.
            %
            % This method will call the sync() method of all registered applications 
            % (iff the application has the method). It's signature is:
            %
            %     function sync(obj, data)
            %         if isfield(data, 'Time')
            %            % ...
            %         end
            %        
            %         % ...
            %     end
            %
            % Recognized fields are (at the moment of writing):
            %
            %     Time              The relative, synchronized time.
            %
            % TODO 
            % - add 'Dataset', 'GlobalTime' etc.?
            % - describe "relative,synchronized time" (somewhere else)
            % - if high playback rates are required, some more optimization is needed (e.g. obj.Objects =
            %   struct(handle=weak-handle,cb=ismethod(handle,'sync'))
            % - MATLAB's struct constructor can produce a struct array if a field value is a cell array (chatGPT)        
            arguments
                obj ana.session
                source = []
            end
            arguments (Repeating)
                args
            end

            if ischar(source) || isstring(source)
                data = struct(source, args{:});
                source = [];
            else
                data = struct(args{:});
            end

            refs = obj.Objects;
            
            for k = 1:numel(refs)
                h = refs{k}.Handle;
            
                if isempty(h) || ~isvalid(h) || isequal(h, source)
                    continue
                end
            
                runcb(refs{k}, data);
            end
        end
    end
end

function runcb(ref,varargin)
    h = ref.Handle;
    
    if ismethod(h, 'sync')
        try
            h.sync(varargin{:});
        catch me
            warning('ana.session:SyncFailed', '%s', ...
                me.getReport('extended', 'hyperlinks', 'on'));
        end
    end
end

% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
