classdef process < handle
    % pam.os.process  Unix-like process execution.
    %
    % USAGE
    %   obj = pam.os.process('cmd', 'argument', ...)
    %
    % PROPERTIES
    %   Input       Input callback (@()).
    %   Output      Output callback (@(msg)).
    %   Error       Error callback (@(msg)).
    %
    % TODO
    % see https://github.com/brian-lau/MatlabProcessManager/blob/master/processManager.m
    
    methods
        function self = process(varargin)
            % Constructor.

            Runtime = java.lang.Runtime.getRuntime();
            
            % invoke process
            try
                if iscell(varargin{end})
                    self.Process = Runtime.exec(varargin(1:end-1), varargin{end});
                elseif isstruct(varargin{end})
                    env = {};
                    
                    s = varargin{end};
                    fn = fieldnames(s);
                    for k = 1:length(fn)
                        env = [env, {[fn{k} '=' s.(fn{k})]}];
                    end
                    
                    self.Process = Runtime.exec(varargin(1:end-1), env);
                else
                    self.Process = Runtime.exec(varargin);
                end
            catch me
%                 warning(me.message);
                return
            end
            
            % process input
            self.InputStream = self.Process.getOutputStream();
            self.ProcessInput = java.io.PrintStream(self.InputStream);
            
            % process output
            self.OutputStream = self.Process.getInputStream();
            self.ProcessOutput = java.io.BufferedReader(java.io.InputStreamReader(self.OutputStream));

            % process error
            self.ErrorStream = self.Process.getErrorStream();
            self.ProcessError = java.io.BufferedReader(java.io.InputStreamReader(self.ErrorStream));
        end
        
        function delete(self)
            try  %#ok<TRYNC>                
                self.Process.destroyForcibly();
            end
        end
    end
    
    properties(Access = protected)
        Process         %java.lang.Process       % Java process handle.
        
        InputStream     %java.io.OutputStream    % Process standard input stream.
        OutputStream    %java.io.InputStream     % Process standard output stream.
        ErrorStream     %java.io.InputStream     % Process standard error stream.

        ProcessInput    %java.io.PrintStream
        ProcessOutput   %java.io.BufferedReader
        ProcessError    %java.io.BufferedReader
    end
    
    properties(Access = public)
        InputCb                                 % Input callback for run() method.
        OutputCb = @(line) pam.util.cprintf('blue', '%s\n', line)
                                                % Output callback for run() method.
        ErrorCb = @(line) pam.util.cprintf('*red', '%s\n', line)
                                                % Error callback for run() method.
        ProgressCb                              % Progress callback.
    end
    
    methods
        % Get standard input of the process.
        function results = stdin(self)
            results = self.InputStream;
        end
        
        % Get standard output of the process.
        function results = stdout(self)
            results = self.OutputStream;
        end
        
        % Get standard error output of the process.
        function results = stderr(self)
            results = self.ErrorStream;
        end

        % Check if process is valid.
        function result = isgood(self)
            result = ~isempty(self.Process);
        end
        
        % Check if process is running.
        function result = isrunning(self)
            result = self.Process.isAlive();
        end
        
        % Check if process has (properly) terminated.
        function result = hasterminated(self)
            result = ~isempty(self.exitValue());
        end
        
        % Kill the subprocess.
        function destroy(self)
            destroy(self.Process)
        end
        
        % Wait for the subprocess to finish.
        %
        % USAGE
        %   exitvalue = process.wait()
        %   status = process.wait(timeout_seconds);
        %
        % exitvalue:    the programs exit value
        % status:       true if the subprocess has exited and false if the 
        %               waiting time elapsed before the subprocess has exited
        % 
        function results = wait(self, timeout)
            if nargin > 1
                java.lang.Thread.sleep(timeout*1000);
                results = ~self.Process.isAlive();
            else
                results = self.Process.wait();
            end
        end
        
        % Get programs exit value.
        function results = exitValue(self)
            if self.isrunning()
                results = [];
            else
                results = self.Process.exitValue();
            end
        end
        
        % Loop in-/output.
        %
        % FIXME
        function results = run(self, type)
            results = [];
            if nargin < 2
                type = 'text';
            end
            
            % check if streams are open
            % FIXME
            
            % loop until exited
            switch type
                case 'text'
                    while self.isrunning() ...
                            || self.ProcessOutput.ready() ...
                            || self.ProcessError.ready()
                        if self.ProcessOutput.ready()
                            self.OutputCb(char(self.ProcessOutput.readLine()));
                        end
                        
                        if self.ProcessError.ready()
                            self.ErrorCb(char(self.ProcessError.readLine()));
                        end

                        if ~isempty(self.InputCb)
                            self.ProcessInput.write(self.InputCb());
                        end
                        
                        if ~self.wait(0.01) && ~isempty(self.ProgressCb)
                            self.ProgressCb();
                        end
                    end
                    
                case 'binary'
                    FIXME()
                    
                otherwise
                    error('Invalid value provided to property ''Type''.')
            end
            
            if  ~isempty(self.ProgressCb)
                self.ProgressCb('Finished', true);
            end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
