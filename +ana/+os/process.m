classdef process < handle
    % ana.os.process    Sub-process builder.
    %
    % TODO: 
    % - documentation for ana.os.process
    % - check if MatlabRuntime is valid on Windows

    %% PROPERTIES
    properties(SetAccess = protected)
        Process java.lang.Process               % Java process handle.

        Input java.io.OutputStream              % Process standard input stream.
        Output java.io.InputStream              % Process standard output stream.
        Error java.io.InputStream               % Process standard error stream.
    end

    properties(Hidden, SetAccess = protected)
        BufferInput java.io.PrintStream         % FIXME
        BufferOutput java.io.BufferedReader     % FIXME
        BufferError java.io.BufferedReader      % FIXME
    end

    properties(Hidden)
        InputCb                 % Input callback for run() method.
        OutputCb                % Output callback for run() method.
        ErrorCb                 % Error callback for run() method.
    end

    %% PUBLIC
    methods
        function self = process(varargin,options)
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


%             Runtime = java.lang.Runtime.getRuntime();
% 
%             % invoke process
%             try
%                 if iscell(varargin{end})
%                     self.Process = Runtime.exec(varargin(1:end-1), varargin{end});
%                 elseif isstruct(varargin{end})
%                     env = {};
% 
%                     s = varargin{end};
%                     fn = fieldnames(s);
%                     for k = 1:length(fn)
%                         env = [env, {[fn{k} '=' s.(fn{k})]}];
%                     end
% 
%                     self.Process = Runtime.exec(varargin(1:end-1), env);
%                 else
%                     self.Process = Runtime.exec(varargin);
%                 end
%             catch me
% %                 warning(me.message);
%                 return
%             end
% 
%             % process input
%             self.InputStream = self.Process.getOutputStream();
%             self.ProcessInput = java.io.PrintStream(self.InputStream);
% 
%             % process output
%             self.OutputStream = self.Process.getInputStream();
%             self.ProcessOutput = java.io.BufferedReader(java.io.InputStreamReader(self.OutputStream));
% 
%             % process error
%             self.ErrorStream = self.Process.getErrorStream();
%             self.ProcessError = java.io.BufferedReader(java.io.InputStreamReader(self.ErrorStream));
        end
        
        function delete(self)
            try  %#ok<TRYNC>                
                self.Process.destroyForcibly();
            end
        end
    end
    
    methods
        % % Get standard input of the process.
        % function results = stdin(self)
        %     results = self.InputStream;
        % end
        % 
        % % Get standard output of the process.
        % function results = stdout(self)
        %     results = self.OutputStream;
        % end
        % 
        % % Get standard error output of the process.
        % function results = stderr(self)
        %     results = self.ErrorStream;
        % end
        % 
        % % Check if process is valid.
        % function result = isgood(self)
        %     result = ~isempty(self.Process);
        % end
        % 
        % % Check if process is running.
        % function result = isrunning(self)
        %     result = self.Process.isAlive();
        % end
        % 
        % % Check if process has (properly) terminated.
        % function result = hasterminated(self)
        %     result = ~isempty(self.exitValue());
        % end
        % 
        % % Kill the subprocess.
        % function destroy(self)
        %     destroy(self.Process)
        % end
        % 
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
        % function results = wait(self, timeout)
        %     if nargin > 1
        %         java.lang.Thread.sleep(timeout*1000);
        %         results = ~self.Process.isAlive();
        %     else
        %         results = self.Process.wait();
        %     end
        % end
        % 
        % % Get programs exit value.
        % function results = exitValue(self)
        %     if self.isrunning()
        %         results = [];
        %     else
        %         results = self.Process.exitValue();
        %     end
        % end
        % 
        % % Loop in-/output.
        % %
        % % FIXME
        % function results = run(self, type)
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
        %             while self.isrunning() ...
        %                     || self.ProcessOutput.ready() ...
        %                     || self.ProcessError.ready()
        %                 if self.ProcessOutput.ready()
        %                     self.OutputCb(char(self.ProcessOutput.readLine()));
        %                 end
        % 
        %                 if self.ProcessError.ready()
        %                     self.ErrorCb(char(self.ProcessError.readLine()));
        %                 end
        % 
        %                 if ~isempty(self.InputCb)
        %                     self.ProcessInput.write(self.InputCb());
        %                 end
        % 
        %                 if ~self.wait(0.01) && ~isempty(self.ProgressCb)
        %                     self.ProgressCb();
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
        %     if  ~isempty(self.ProgressCb)
        %         self.ProgressCb('Finished', true);
        %     end
        % end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
