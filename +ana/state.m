classdef state < handle
    %ana.state      The application state (akin to global variables).
    %
    %   The ANA.STATE serves as persistent storage for the life-time of application,
    %   also allowing synchronization of time between applications.
    %
    %   FIXME
    %

    %% PROPERTIES
    properties(SetAccess=protected)
        SyncCB = {}
        Data ana.type.dict
    end

    properties(Hidden,Access=private)
        Instance = false
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
            %STATE Construct an instance of this class
            persistent singleton
            if isempty(singleton)
                obj.Instance = true;
                singleton = obj;
                return
            end
            obj = singleton;
        end

        function obj = set(obj,varargin)
            %SET        FIXME
            for k = 1:2:numel(varargin)
                key = varargin{k};
                value = varargin{k};

                switch (key)
                    otherwise
                end
            end
        end

        function obj = add(obj,varargin)
            %ADD        FIXME
            for k = 1:2:numel(varargin)
                key = varargin{k};
                value = varargin{k};

                switch (key)
                    case 'SyncCB'
                        obj.SyncCB{end+1} = value;
                    otherwise
                end
            end
        end

        function obj = remove(obj,varargin)
            %REMOVE     FIXME
            
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
