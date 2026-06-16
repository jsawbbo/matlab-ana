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
    %
    % Callbacks:
    %
    %
    %
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
        InputMode

        BufferedOutput %java.io.BufferedReader  % FIXME
        OutputMode

        BufferedError %java.io.BufferedReader   % FIXME
        ErrorMode
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
                options.InputMode = 'binary'
                options.OutputMode = 'text'
                options.ErrorMode = 'text'
                options.Charset = 'UTF-8'
            end

            jargs = javaArray('java.lang.String', numel(varargin));
            for k = 1:numel(varargin)
                jargs(k) = java.lang.String(char(varargin{k}));
            end

            build = java.lang.ProcessBuilder(jargs);

            % environment
            env = build.environment();

            if ~options.MatlabRuntime
                % remove Matlab environment from LD_LIBRARY_PATH
                paths = env.get('LD_LIBRARY_PATH');
                if ~isempty(paths)
                    paths = split(string(paths), ':');
                    bad = contains(paths, {'MATLAB','MathWorks'});
                    assert(any(size(bad)==1), "ANA:internalError", "Internal error: expected a 1-dimensional array.")
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

            % modes, buffering and callbacks
            charset = java.nio.charset.Charset.forName(options.Charset);

            obj.InputMode = options.InputMode;
            obj.InputCb = options.Input;
            switch (obj.InputMode)
                case 'binary'
                    % nothing to be done
                case 'text'
                    obj.BufferedInput = java.io.PrintStream(obj.Input,charset);
                otherwise
                    error("ANA:os:process:invalidInputMode", "Invalid input mode '%s', must be 'text' or 'binary'.", obj.InputMode)
            end

            obj.OutputMode = options.OutputMode;
            obj.OutputCb = options.Output;
            switch (obj.OutputMode)
                case 'binary'
                    % nothing to be done
                case 'text'
                    obj.BufferedOutput = java.io.BufferedReader(java.io.InputStreamReader(obj.Output,charset));
                otherwise
                    error("ANA:os:process:invalidOutputMode", "Invalid input mode '%s', must be 'text' or 'binary'.", obj.OutputMode)
            end

            obj.ErrorMode = options.ErrorMode;
            obj.ErrorCb = options.Error;
            switch (obj.ErrorMode)
                case 'binary'
                    % nothing to be done
                case 'text'
                    obj.BufferedError = java.io.BufferedReader(java.io.InputStreamReader(obj.Error,charset));
                otherwise
                    error("ANA:os:process:invalidErrorMode", "Invalid input mode '%s', must be 'text' or 'binary'.", obj.ErrorMode)
            end
        end
        
        function delete(obj)
            obj.stop();

            try  
                if obj.Process.isAlive()
                    obj.Process.destroyForcibly();
                end
            catch
            end
        end
    end

    methods
        function result = isrunning(obj)
            %ISRUNNING      Check if process is running.
            result = obj.Process.isAlive();
        end

        function result = exited(obj)
            %EXITED         Check if process has exited normally.
            %
            %   This method returns `true` if the program exited normally
            %   (which means, it has returned an exit value), `false` otherwise 
            %   (for example, because the process was "killed" by the user).
            %
            result = ~isempty(obj.exitValue());
        end

        function close(obj)
            %CLOSE          Close connection.
            try obj.Input.flush(); catch, end
            try obj.Input.close(); catch, end
        end

        function stop(obj)
            %STOP           Stop sub-process.
            try obj.Input.close(); catch, end
            try obj.Output.close(); catch, end
            try obj.Error.close(); catch, end
        
            try
                if obj.Process.isAlive()
                    obj.Process.destroy();
                end
            catch
            end 
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

        function res = run(obj)
            %RUN        Run program.
            % 
            %   FIXME
            while true
                while true
                    % check if we have data to read/process
                    [out,err] = obj.available();
                    if ~out && ~err
                        break
                    end
    
                    % process program's stdout
                    if out && ~isempty(obj.OutputCb)
                        if isempty(obj.BufferedOutput)
                            FIXME
                        else
                            obj.OutputCb(char(obj.BufferedOutput.readLine()));
                        end
                    end
    
                    % process program's stderr
                    if err && ~isempty(obj.ErrorCb)
                        if isempty(obj.BufferedError)
                            FIXME
                        else
                            obj.ErrorCb(char(obj.BufferedError.readLine()));
                        end
                    end
                end

                if isempty(obj.InputCb)
                    break
                else
                    data = obj.InputCb();
                    if isempty(data)
                        res = false;
                    else 
                        res = obj.write(data);
                        if isempty(res) || (res == 0)
                            res = false;
                        end
                    end
                end

                if ~res && ~obj.isrunning()
                    break
                end
            end

            res = obj.isrunning();
        end

        function res = write(obj,buf)
            %WRITE      Write data to program's stdin.
            %
            % FIXME buf = typecast(reshape(uint8(data).', [], 1), 'int8');

            if isempty(obj.BufferedInput)
                try
                    obj.Input.write(buf);
                    obj.Input.flush();
                    res = true;
                catch
                    res = false;
                end
            else
                try
                    obj.BufferedInput.write(buf);
                    obj.BufferedInput.flush();
                    res = true;
                catch
                    res = false;
                end
            end
        end

        function res = read(obj)
            %READ       Read data from program's stdout.
            if isempty(obj.BufferedOutput)
                res = obj.Output.read();
            else
                res = obj.BufferedOutput.readLine();
            end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
%
% Development assistance:
%   ChatGPT (OpenAI, GPT-5.5)
