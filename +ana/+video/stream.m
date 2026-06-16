classdef stream < handle
    %ana.video.stream          Video en-, trans- or decoder (based on ffmpeg).
    %
    % TODO: 
    % - documentation
    % - examples, e.g. ffmpeg -i CADDX000003-%06d.png -c:v libx265 -pix_fmt gray -x265-params lossless=1 output.mp4

    %% PROPERTIES
    properties
        Input = struct(...                  % Input
            File = [], ...                  % Input filename (empty if using write()).
            Format = [], ...                % Input format (such as "rawvideo").
            FrameRate = [], ...             % Input frame-rate.
            FrameSize = [], ...             % Input geometry ([w h]).
            PixelFormat = [], ...           % Input pixel format (e.g. "gray8").
            Reserved=[]);

        Filter = struct(...                 % Filter
            Instruction = [], ...           % Filter instruction (as used by ffmpeg).
            Reserved=[])

        Output = struct(...                 % Output
            File = [], ...                  % Output filename (empty if using read()).
            FrameRate = [], ...             % Output frame rate.
            FrameSize = [], ...             % Output geometry (if different from input).
            PixelFormat = 'yuv444p', ...    % Output pixel format (e.g. "rgb24", default: "yuv444p").
            Codec = 'libx264', ...          % Video codec.
            ConstantRateFactor = 18,...     % Depends on codec, for libx264 a value of 0 is lossless and 51 worst losses.
            ExtraParams = [],...            % Additional command-line parameters.
            Reserved=[]);
    end

    properties(SetAccess=protected)
        Process
    end

    %% Helper
    methods(Hidden)
        function args = handleParam(~,args,param)
            fn = fieldnames(param);
            for k = 1:numel(fn)
                key = fn{k};
                if ~isempty(param.(key))
                    switch key
                        case 'File'
                            % see build()
                        case 'Format'
                            args = [args(:)',"-f",string(param.Format)];
                        case 'FrameRate'
                            args = [args(:)',"-r",string(param.FrameRate)];
                        case 'FrameSize'
                            args = [args(:)',"-s",strjoin(string(param.FrameSize),"x")];
                        case 'PixelFormat'
                            args = [args(:)',"-pix_fmt",string(param.PixelFormat)];
                        case 'Codec'
                            args = [args(:)',"-vcodec",string(param.Codec)];
                        case 'ConstantRateFactor'
                            args = [args(:)',"-crf",string(param.ConstantRateFactor)];
                        case 'ExtraParams'
                            extra = cellfun(@(s) string(s),param.ExtraParams,UniformOutput=false);
                            args = [args(:)',extra{:}];
                        otherwise
                            error('ANA:internalError', 'internal error: unknown key: %s', key)
                    end
                end
            end    
        end
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

            args = ["ffmpeg", "-y"];
            
            args = obj.handleParam(args,obj.Input);

            if isempty(obj.Input.File)
                args = [args(:)',"-i","-"];
            else
                args = [args(:)',"-i",obj.Input.File];
            end

            args = obj.handleParam(args,obj.Output);

            if isempty(obj.Output.File)
                % nothing to do
            else
                args = [args(:)',obj.Output.File];
            end
                
            args = cellstr(args);
            proc = ana.os.process(args{:}, OutputMode='binary');
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

        function close(obj)
            %CLOSE      Close stream.
            obj.Process.close();
            while obj.Process.isrunning()
                pause(0.001);
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
