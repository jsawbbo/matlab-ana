classdef stream < handle
    %ana.video.stream          Video en-, trans- or decoder (based on ffmpeg).
    %
    % TODO: documentation

    %% PROPERTIES
    properties
        Input = struct(...                  % Input
            File = [], ...                  % Input filename (empty if using write()).
            Format = [], ...                % FIXME (e.g. rawvideo)
            FrameRate = [], ...             %
            FrameSize = [], ...             %
            PixelFormat = [], ...           %
            Reserved=[]);

        Filter = struct(...                 % Filter
            Instruction = [], ...           % Filter instruction (as used by ffmpeg).
            Reserved=[])

        Output = struct(...                 % Output
            File = [], ...                  % Output filename (empty if using read()).
            FrameRate = [], ...             %
            FrameSize = [], ...             %
            PixelFormat = 'yuv444p', ...    % Output pixel format (default: yuv444p).
            Codec = 'libx264', ...          % Video codec
            ConstantRateFactor = 18,...     % Depends on codec, for libx264 a value of 0 is lossless and 51 worst losses.
            Reserved=[]);
    end

    properties(SetAccess=protected)
        Process
    end

    %% Helper
    methods(Hidden)
    end

    %% PUBLIC
    methods
        function obj = stream()
            %STREAM         Create an instance of this class.
        end

        function obj = input(obj,varargin)
            %INPUT      Set input parameters.
            for k = 1:2:numel(varargin)
                key = varargin{k};
                value = varargin{k+1};

                assert(isfield(obj.Input,key), "ANA:os:process:invalidInputProperty", "No such input property: '%s'", key)

                obj.Input.(key) = value;
            end
        end

        function obj = filter(obj,varargin)
            %FILTER     Set filter parameters.
            for k = 1:2:numel(varargin)
                key = varargin{k};
                value = varargin{k+1};

                assert(isfield(obj.Filter,key), "ANA:os:process:invalidFilterProperty", "No such filter property: '%s'", key)

                obj.Filter.(key) = value;
            end
        end

        function obj = output(obj,varargin)
            %OUTPUT     Set output parameters.
            for k = 1:2:numel(varargin)
                key = varargin{k};
                value = varargin{k+1};

                assert(isfield(obj.Output,key), "ANA:os:process:invalidOutputProperty", "No such output property: '%s'", key)

                obj.Output.(key) = value;
            end
        end

        function proc = build(obj)
            %BUILD      Build process.
            %

            % args = ["ffmpeg", "-y"];
            % 
            % if ~isempty(obj.InputFormat)
            %     args = [args(:)',"-f",obj.InputFormat];
            % end
            % 
            % if ~isempty(obj.FrameSize)
            %     args = [args(:)',"-s",strjoin(string(obj.FrameSize),'x')];
            % end
            % 
            % if ~isempty(obj.InputPixelFormat)
            %     args = [args(:)',"-pix_fmt",obj.InputPixelFormat];
            % end
            % 
            % if ~isempty(obj.FrameRate)
            %     args = [args(:)',"-r",obj.FrameRate];
            % end
            % 
            % if isempty(obj.InputFile)
            %     args = [args(:)',"-i","-"];
            % else
            %     args = [args(:)',"-i",obj.InputFile];
            % end
            % 
            % if ~isempty(obj.Filter)
            %     args = [args(:)',"-filter_complex",obj.Filter];
            % end
            % 
            % if ~isempty(obj.FrameRate)
            %     args = [args(:)',"-r",obj.FrameRate];
            % end
            % 
            % if ~isempty(obj.FrameRate)
            %     args = [args(:)',"-crf",string(obj.ConstantRateFactor)];
            % end
            % 
            % args = [args(:)',...
            %     "-vcodec",obj.Codec,...
            %     "-pix_fmt",obj.PixelFormat];
            % 
            % if isempty(obj.OutputFile)
            %     % nothing to do
            % else
            %     args = [args(:)',obj.OutputFile];
            % end
            % 
            % proc = ana.os.process(args(:), OutputMode='binary');
            % obj.Process = proc;
        end

        function res = run(obj)
            %RUN        Run independently
            res = obj.Process.run();
        end

        function res = write(obj,data)
            %WRITE      Write data to ffmpeg.
            res = obj.Process.write(data);
        end

        function res = read(obj)
            %READ       Read data from ffmpeg.
            res = obj.Process.Output.read();
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
