classdef process < handle
    % ana.os.process    Sub-process builder.
    %   
    %   proc = ana.os.process('command', 'args', ..., <options>...)
    %
    % Options:
    %   Input=@callback
    %   Output=@callback
    %   Error=@callback     (default: ana.log.error)
    %
    % TODO: 
    % - documentation for ana.os.process
    % - check if MatlabRuntime is valid on Windows

    %% PROPERTIES
    properties(SetAccess = protected)
        Process %java.lang.Process              % Java process handle.
    end

    properties
        Input %java.io.OutputStream             % Process' standard input stream.
        Output %java.io.InputStream             % Process' standard output stream.
        Error %java.io.InputStream              % Process' standard error stream.
    end

    properties(Hidden, SetAccess = protected)
        BufferedInput %java.io.PrintStream      % FIXME
        BufferedOutput %java.io.BufferedReader  % FIXME
        BufferedError %java.io.BufferedReader   % FIXME
    end

    properties(Hidden)
        InputCb                                 % Process input callback.
        OutputCb                                % Process output callback.
        ErrorCb                                 % Process error callback.
    end

    %% PROTECTED
    methods(Access=protected)

    end

    %% PUBLIC
    methods
        function obj = process(varargin,options)
            %PROCESS    Constructor.
            arguments(Repeating)
                varargin
            end
            arguments
                options.MatlabRuntime = false       % Flag, if MATLAB paths should be accepted in LD_LIBRARY_PATH.
                options.Environment = []            % Environment variables {<key>=<value>,...}.
                options.Input = []                  % Program input callback.
                options.Output = []                 % Program output callback.
                options.Error = @ana.log.error      % Program error callback (default: ana.log.error).
            end

            args = java.util.Arrays.asList(string(varargin));
            build = java.lang.ProcessBuilder(args);

            % environment
            env = build.environment();

            if ~options.MatlabRuntime
                % remove Matlab environment from LD_LIBRARY_PATH
                paths = env.get('LD_LIBRARY_PATH');
                if ~isempty(paths)
                    paths = split(string(paths), ':');
                    bad = contains(paths, {'MATLAB','MathWorks'});
                    env.put('LD_LIBRARY_PATH', strjoin(paths(~bad),':'));
                end
            end

            for k = 1:2:numel(options.Environment)
                env.put(options.Environment{k},options.Environment{k+1});
            end

            % start process, get streams
            obj.Process = build.start();
            obj.Input = obj.Process.getOutputStream();
            obj.Output = obj.Process.getInputStream();
            obj.Error = obj.Process.getErrorStream();

            % callbacks and buffering
            if ~isempty(options.Input)
                obj.InputCb = options.Input;
            end

            if ~isempty(options.Output)
                if isa(options.Output, 'function_handle')
                    obj.BufferedOutput = java.io.BufferedReader(java.io.InputStreamReader(obj.Output));
                    obj.OutputCb = options.Output;
                else
                    FIXME
                end
            end

            if ~isempty(options.Error)
                if isa(options.Error, 'function_handle')
                    obj.BufferedError = java.io.BufferedReader(java.io.InputStreamReader(obj.Error));
                    obj.ErrorCb = options.Error;
                else
                    FIXME
                end
            end

%             obj.ProcessOutput = java.io.BufferedReader(java.io.InputStreamReader(obj.OutputStream)); or binary BufferedInputStream
%             obj.ProcessError = java.io.BufferedReader(java.io.InputStreamReader(obj.ErrorStream));
        end
        
        function delete(obj)
            try  %#ok<TRYNC>                
                obj.Process.destroyForcibly();
            end
        end
    end

    methods
        function result = isrunning(obj)
            %ISRUNNING      Check if process is running.
            result = obj.Process.isAlive();
        end

        function result = terminated(obj)
            %TERMINATED     Check if process has (properly) terminated.
            result = ~isempty(obj.exitValue());
        end

        function destroy(obj)
            %DESTROY        Destroy the subprocess.
            destroy(obj.Process)
        end

        function results = exitValue(obj)
            %EXITVALUE      Get exit value from process.
            if obj.isrunning() || ~obj.isvalid()
                results = [];
            else
                results = obj.Process.exitValue();
            end
        end

        function [out,err] = available(obj)
            %READY      Check if data can be read from process.

            if isempty(obj.BufferedOutput)
                out = (obj.Output.available() > 0);
            else
                out = obj.BufferedOutput.ready();
            end

            if isempty(obj.BufferedError)
                err = (obj.Error.available() > 0);
            else
                err = obj.BufferedError.ready();
            end
        end

        function res = step(obj)
            %STEP FIXME
            while obj.isrunning()
                [out,err] = obj.available();
                if ~out && ~err
                    break
                end

                if out 
                    obj.handle()
                end

                if err
                end
            end
            res = obj.isrunning();
        end

        % % Wait for the subprocess to finish.
        % %
        % % USAGE
        % %   exitvalue = process.wait()
        % %   status = process.wait(timeout_seconds);
        % %
        % % exitvalue:    the programs exit value
        % % status:       true if the subprocess has exited and false if the 
        % %               waiting time elapsed before the subprocess has exited
        % % 
        % function results = wait(obj, timeout)
        %     if nargin > 1
        %         java.lang.Thread.sleep(timeout*1000);
        %         results = ~obj.Process.isAlive();
        %     else
        %         results = obj.Process.wait();
        %     end
        % end
        % 
        % % Get programs exit value.
        % 
        % % Loop in-/output.
        % %
        % % FIXME
        % function results = run(obj, type)
        %     results = [];
        %     if nargin < 2
        %         type = 'text';
        %     end
        % 
        %     % check if streams are open
        %     % FIXME
        % 
        %     % loop until exited
        %     switch type
        %         case 'text'
        %             while obj.isrunning() ...
        %                     || obj.ProcessOutput.ready() ...
        %                     || obj.ProcessError.ready()
        %                 if obj.ProcessOutput.ready()
        %                     obj.OutputCb(char(obj.ProcessOutput.readLine()));
        %                 end
        % 
        %                 if obj.ProcessError.ready()
        %                     obj.ErrorCb(char(obj.ProcessError.readLine()));
        %                 end
        % 
        %                 if ~isempty(obj.InputCb)
        %                     obj.ProcessInput.write(obj.InputCb());
        %                 end
        % 
        %                 if ~obj.wait(0.01) && ~isempty(obj.ProgressCb)
        %                     obj.ProgressCb();
        %                 end
        %             end
        % 
        %         case 'binary'
        %             FIXME()
        % 
        %         otherwise
        %             error("ANA:runtime:invalidArgument", "invalid value provided to property 'Type'.")
        %     end
        % 
        %     if  ~isempty(obj.ProgressCb)
        %         obj.ProgressCb('Finished', true);
        %     end
        % end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
