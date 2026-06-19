classdef process < handle
    % ana.os.process    Sub-process execution.
    % 
    % Akin to Matlab's <a href="matlab:help system">system</a> command, this class provides the possibility to
    % execute sub-processes and connect or deal with the process' <a href="https://en.wikipedia.org/wiki/Standard_streams">standard streams</a>
    % using the underlying Java language (java.lang.Process).
    %
    % A process can be created with
    %
    %     proc = ana.os.process('command', 'args...', ..., <options>...)
    %
    % (note that program arguments that are separated on the command-line by a space
    % must be passed to ana.os.process as individual command arguments).
    %
    % Options:
    %     MatlabRuntime=<logical>           If `true`, the command is executed within Matlab's
    %                                       runtime environment (default: false).
    %     Environment={...}                 List of environment variables that should be passed
    %                                       to the process in addition to the normal environment 
    %                                       variables (e.g. Environment={MY_VAR=1.0}).
    %     Charset="<charset>"               The character set for any stream in text mode 
    %                                       (default: UTF-8).
    %     Input=<stdin settings>            See below.
    %     Output=<stdout settings>          See below.
    %     Error=<stderr settings>           See below 
    %                                       (defaults: text mode and callback ana.log.error).
    %
    % The stream settings can be either the mode ("text" or "binary") or a callback. 
    % Alternatively it can be list (cell) of mode, callback and character-set
    % (e.g. Output={"text",@ana.log.info,"C"}).
    %

    %% PROPERTIES
    properties(SetAccess = protected)
        Process                         % Process handle (java.lang.Process).

        StdIn                           % Standard input stream of the process.
        StdOut                          % Standard output stream of the process.
        StdErr                          % Standard error stream of the process.

        Charset                         % Default character set.
    end

    properties(SetAccess = protected)
        BufIn                           % Input stream buffer.
        BufOut                          % Output stream buffer.
        BufErr                          % Error stream buffer.

        CbIn                            % Input stream callback.
        CbOut                           % Output stream callback.
        CbErr                           % Error stream callback.
    end
       
    properties
        Blocksize = 4096                % Default for block-wise binary reads.
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
                options.Input = []                  % Process' standard input settings.
                options.Output = []                 % Process' standard output settings.
                options.Error = []                  % Process' standard error settings.
                options.Charset = 'UTF-8'           % Text-mode character set (default: "UTF-8").
            end

            jargs = javaArray('java.lang.String', numel(varargin));
            for k = 1:numel(varargin)
                jargs(k) = java.lang.String(char(varargin{k}));
            end

            build = java.lang.ProcessBuilder(jargs);

            % environment
            env = build.environment();

            if ~options.MatlabRuntime
                % TODO:
                % - check if MatlabRuntime works on Windows

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
            obj.StdIn = obj.Process.getOutputStream();
            obj.StdOut = obj.Process.getInputStream();
            obj.StdErr = obj.Process.getErrorStream();

            % default character set
            obj.Charset = options.Charset;

            % standard stream options
            moreopts = {"Input","Output","Error"};
            for k = 1:3
                opt = moreopts{k};

                % defaults
                mode = 'text';
                charset = obj.Charset;
                switch (opt)
                    case "Input"
                        callback = [];
                    case "Output"
                        callback = [];
                    case "Error"
                        callback = @ana.log.error;
                end

                % user settings
                user = options.(opt);
                if ~isempty(user)
                    if ischar(user) || isstring(user) || isa(user,'function_handle')
                        user = {user};
                    end

                    assert(iscell(user), "ANA:os:process:invalidStreamParam","Invalid parameters passed to %s", opt);

                    for n = 1:numel(user)
                        value = user{n};

                        if ischar(value) || isstring(value)
                            switch value
                                case {"text","binary"}
                                    mode = value;
                                otherwise
                                    charset = value;
                            end
                        elseif isa(value,'function_handle')
                            callback = value;
                        else
                            error("ANA:os:process:invalidStreamParam","Invalid parameters passed to %s", opt);
                        end
                    end
                end

                % checks
                switch (mode)
                    case {"text","binary"}
                    otherwise
                        error("ANA:os:process:invalidStreamParam","Invalid mode for %s: %s", opt, mode);
                end

                if isempty(charset)
                    charset = obj.Charset;
                end
                charset = java.nio.charset.Charset.forName(charset);

                % setup 
                switch (opt)
                    case "Input"
                        switch (mode)
                            case "text"
                                obj.BufIn = java.io.PrintWriter(java.io.OutputStreamWriter(obj.StdIn,charset));
                            case "binary"
                                % FIXME
                        end
                        obj.CbIn = callback;
                    case "Output"
                        switch (mode)
                            case "text"
                                obj.BufOut = java.io.BufferedReader(java.io.InputStreamReader(obj.StdOut,charset));
                            case "binary"
                                % nothing to be done
                        end
                        obj.CbOut = callback;
                    case "Error"
                        switch (mode)
                            case "text"
                                obj.BufErr = java.io.BufferedReader(java.io.InputStreamReader(obj.StdErr,charset));
                            case "binary"
                                % nothing to be done
                        end
                        obj.CbErr = callback;
                end
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

        function results = exitValue(obj)
            %EXITVALUE      Get exit value from process.
            %
            % This method returns the programs exit code if the program
            % exited normally. Otherwise, the result is an empty array.
            %
            results = obj.Process.exitValue();
        end

        function close(obj)
            %CLOSE          Close connection.
            % 
            % This method flushes and closes the programs standard input,
            % commonly used to signal the sub-process the end of data
            % transmission.
            %
            % See also: ana.os.process.stop
            try obj.StdIn.flush(); catch, end
            try obj.StdIn.close(); catch, end
        end

        function stop(obj)
            %STOP           Stop sub-process.
            %
            % Close all standard streams and destroy the process.
            %
            try obj.StdIn.close(); catch, end
            try obj.StdOut.close(); catch, end
            try obj.StdErr.close(); catch, end
        
            try
                if obj.Process.isAlive()
                    obj.Process.destroy();
                end
            catch
            end 
        end

        function [out,err] = available(obj)
            %AVAILABLE      Check if data can be read from process.
            %
            if isempty(obj.BufOut)
                out = (obj.StdOut.available() > 0);
            else
                out = obj.BufOut.ready();
            end

            if isempty(obj.BufErr)
                err = (obj.StdErr.available() > 0);
            else
                err = obj.BufErr.ready();
            end
        end

        function res = run(obj)
            %RUN        Run program.
            % 
            % This function "runs" one iteration which covers feeding the callbacks.
            % 
            %
            hasoutputcb = ~isempty(obj.CbOut);
            haserrorcb = ~isempty(obj.CbErr);
            hasinputcb = ~isempty(obj.CbIn);

            while true
                % === output,error handling
                while true
                    % check if we have data to read/process
                    [out,err] = obj.available();
                    if ~out && ~err
                        break
                    end
    
                    % process program's stdout
                    if out && hasoutputcb
                        if isempty(obj.BufOut)
                            obj.CbOut(char(obj.StdOut.read(obj.Blocksize)));
                        else
                            obj.CbOut(char(obj.BufOut.readLine()));
                        end
                    end
    
                    % process program's stderr
                    if err && haserrorcb
                        if isempty(obj.BufErr)
                            obj.CbErr(char(obj.StdErr.read(obj.Blocksize)));
                        else
                            obj.CbErr(char(obj.BufErr.readLine()));
                        end
                    end
                end

                % === input handling if applicable
                if hasinputcb
                    data = obj.CbIn();
                    if isempty(data)
                        res = false;
                    else 
                        res = obj.write(data);
                        if isempty(res) || (res == 0)
                            res = false;
                        end
                    end
                else
                    break
                end

                if ~res && ~obj.isrunning()
                    break
                end
            end

            res = obj.isrunning();
        end

        function res = write(obj,buf)
            %WRITE      Write data to program's standard input stream.
            %
            % Write binary (int8 or uint8) data to the programs standard input or the buffer.
            %

            if isempty(obj.BufIn)
                try
                    obj.StdIn.write(buf);
                    obj.StdIn.flush();
                    res = true;
                catch
                    res = false;
                end
            else
                try
                    obj.BufIn.write(buf);
                    obj.BufIn.flush();
                    res = true;
                catch
                    res = false;
                end
            end
        end

        function res = read(obj)
            %READ       Read data from program's standard output stream.
            %
            % In text mode, reads a line, otherwise a block of data.
            %
            if isempty(obj.BufOut)
                res = obj.StdOut.read(obj.Blocksize);
            else
                res = obj.BufOut.readLine();
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
