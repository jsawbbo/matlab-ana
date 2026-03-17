classdef shared < handle & matlab.mixin.indexing.RedefinesDot
    %ana.util.shared        Shared data object.
    %
    %   Generic shared data object (or handle, respectively).
    %
    %   The main purpose of this class is to facilitate global static
    %   class members (in terms of C++). This class behaves like a struct.
    %
    %   Example:
    % 
    %       classdef MyClass
    %           properties (Constant)
    %               AppData = ana.util.shared(...
    %                   struct(initialized=false))
    %           end
    %           
    %           methods
    %               function obj = MyClass()
    %                   if ~obj.AppData.initialized
    %                       % ...
    %                   end
    %               end
    %           end
    %       end
    %
    %   Note: Handling the shared data should always be handled by making a copy. 
    %   In the example above, use 
    %
    %       appdata = path.to.MyClass.AppData;
    %
    %   before accessing it. Otherwise Matlab will not recognize "path.to.".
    %

    properties (Hidden,Access=private)
        InternalData = struct()
    end

    methods(Hidden)
        function res = properties(obj)
            res = fieldnames(obj.InternalData);
        end        

        function res = fieldnames(obj)
            res = fieldnames(obj.InternalData);
        end

        function disp(obj)
            fprintf('  <a href="matlab:help ana.util.shared">ana.util.shared</a> with properties:\n\n')
            fn = fieldnames(obj.InternalData);
            for i = 1:length(fn)
                val = obj.InternalData.(fn{i});
                try
                    fprintf("    %s: %s\n", fn{i}, string(val))
                catch
                    fprintf("    %s: [%s]\n", fn{i}, class(val))
                end
            end
            fprintf("\n")
        end
    end

    methods (Access=protected)
        function n = dotListLength(obj,indexOp,indexContext)
            n = listLength(obj.InternalData,indexOp,indexContext);
        end

        function varargout = dotReference(obj,indexOp)
            [varargout{1:nargout}] = obj.InternalData.(indexOp);
        end

        function obj = dotAssign(obj,indexOp,varargin)
            [obj.InternalData.(indexOp)] = varargin{:};
        end
    end
    
    methods
        function obj = shared(data)
            %SHARED     Construct an instance of this class
            if nargin > 0
                if isstruct(data)
                    obj.InternalData = data;
                else
                    assert(isstruct(data), "argument must be a struct")
                end
            end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
