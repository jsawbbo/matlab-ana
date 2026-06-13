classdef transcode < handle
    %TRANSCODE          En- or transcode video.
    %
    % TODO: documentation

    properties
        FrameRate                   % Frame rate (in- and output).
        FrameSize                   % Frame size.

        InputFile                   % Input filename (empty for using ffmpeg's stdin).
        InputFormat                 % Input format.
        InputPixelFormat            % Input pixel format.

        OutputFile                  % Output filename (empty for using ffmpeg's stdout).

        Filter                      % FFmpeg filter instructions.
        VideoCodec = "libx264"      % Video codec (default: libx264).
        PixelFormat = 'yuv420p'     % Pixel format (default: yuv420p).
        ConstantRateFactor = 18     % Depends on codec, for libx264 a value of 0 is lossless and 51 worst losses.
    end

    properties(SetAccess=protected)
        Process
    end

    methods
        function obj = transcode(varargin)
            %TRANSCODE      Create an instance of this class.
            arguments(Repeating)
                varargin
            end

            for k = 1:2:numel(varargin)
                prop = varargin{k};
                assert(isprop(obj,prop), "ANA:os:process:invalidProperty", "No such property: '%s'", prop)

                obj.(prop) = varargin{k+1};
            end
        end

        function proc = make(obj)
            %MAKE       Build process.
            %

            args = ["ffmpeg", "-y"];

            if ~isempty(obj.InputFormat)
                args = [args(:)',"-f",obj.InputFormat];
            end

            if ~isempty(obj.FrameSize)
                args = [args(:)',"-s",strjoin(string(obj.FrameSize),'x')];
            end

            if ~isempty(obj.InputPixelFormat)
                args = [args(:)',"-pix_fmt",obj.InputPixelFormat];
            end

            if ~isempty(obj.FrameRate)
                args = [args(:)',"-r",obj.FrameRate];
            end

            if isempty(obj.InputFile)
                args = [args(:)',"-i","-"];
            else
                args = [args(:)',"-i",obj.InputFile];
            end

            if ~isempty(obj.Filter)
                args = [args(:)',"-filter_complex",obj.Filter];
            end

            if ~isempty(obj.FrameRate)
                args = [args(:)',"-r",obj.FrameRate];
            end

            if ~isempty(obj.FrameRate)
                args = [args(:)',"-crf",string(obj.ConstantRateFactor)];
            end

            args = [args(:)',...
                "-vcodec",obj.VideoCodec,...
                "-pix_fmt",obj.PixelFormat];

            if isempty(obj.OutputFile)
                % nothing to do
            else
                args = [args(:)',obj.OutputFile];
            end
            
            proc = ana.os.process(args(:), OutputMode='binary');
            obj.Process = proc;
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
