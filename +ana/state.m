classdef state < handle
    %ana.state      The application state (akin to global variables).
    %
    %   The ANA.STATE serves as persistent storage for the life-time of the application,
    %   also allowing synchronization of time between applications.
    %
    %   FIXME
    %

    %% PROPERTIES
    properties(SetAccess=protected)
        UserData ana.type.dict              % User data.
    end

    properties(Hidden)
        SyncCB = {}                         % Synchronization callbacks.
        LogLevel = ana.log.level.INFO       % Global log level.
        LogFile = []                        % Log file descriptor (see ana.log.to)
    end

    properties(Hidden,Access=private)
        Instance = false                    % Flag, only true for actual singleton instance.
    end

    %% STATIC
    methods(Static)
    end

    %% PROTECTED
    methods(Access=protected)
        function delete(obj)
            %DELETE Delete this object.
            if obj.Instance
                %TODO save state if necessary
            end
        end
    end

    %% PUBLIC
    methods
        function obj = state()
            %STATE      Construct a singleton instance of this class.
            persistent singleton
            if isempty(singleton)
                obj.Instance = true;
                singleton = obj;
            else
                obj = singleton;
            end
        end

        function obj = set(obj,varargin)
            %SET        Set global variables.
            %
            %       ana.state().set(<key>,<value>,...)
            %       ana.state().set(<key>=<value>,...)
            %
            % Set a single or multiple values by key.
            %
            arguments
                obj ana.state
            end
            arguments(Repeating)
                varargin
            end

            for k = 1:2:numel(varargin)
                key = varargin{k};
                value = varargin{k+1};
                obj.UserData(string(key)) = value;
            end
        end

        function obj = remove(obj,varargin)
            %REMOVE     Remove global variable.
            %
            %       ana.state().set('<key>')
            %       ana.state().set('<key1>','<key2>',...)
            %       ana.state().set({'<key1>','<key2>',...})
            %   
            % Remove one or multiple entries by key.
            %
            arguments
                obj ana.state
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
                obj.UserData.remove(key);
            end
        end

        function res = get(obj,varargin)
            %GET        Get global variables.
            %
            %       ana.state().get()
            % 
            % Get a copy of all entries.
            %
            %       ana.state().get("<key>")
            %
            % Retrieve a single entry.
            %
            %       ana.state().get("<key1>","<key2>")
            %       ana.state().get({"<key1>","<key2>"})
            %
            % Retrieve a multiple entries.

            arguments
                obj ana.state
            end
            arguments(Repeating)
                varargin
            end

            if nargin == 1
                res = obj.UserData;
                return
            elseif nargin == 2
                if iscell(varargin{1})
                    args = varargin{1};
                else
                    key = string(varargin{1});
                    if isfield(obj.UserData, key)
                        res = obj.UserData(key);
                    else
                        res = [];
                        warning("No such key in ana.state's UserData: '%s'", key);
                    end
                    return
                end
            else
                args = varargin;
            end

            res = ana.type.dict();
            for k = 1:numel(args)
                key = string(args{k});
                if isfield(obj.UserData, key)
                    res(key) = obj.UserData(key);
                else
                    res(key) = [];
                    warning("No such key in ana.state's UserData: '%s'", key);
                end
            end
        end
    end

    methods 
        function sync(obj,t)
            %SYNC   Synchronize time among registered applications.
            %
            valid = cellfun(@(fn) runcb(fn,t), obj.SyncCB, UniformOutput=true);
            if ~all(valid)
                % auto-remove invalid entries
                obj.SyncCB = obj.SyncCB(valid);
            end
        end
    end
end

function valid = runcb(fn,varargin)
    try
        fn(varargin{:});
        valid = true;
    catch
        valid = false;
    end
end

% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
