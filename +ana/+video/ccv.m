classdef ccv < handle
    %ana.video.ccv          CCV video reader.
    %

    %% PROPERTIES
    properties(SetAccess=protected)
        FilePath
        
        Version

        Camera
        ImageType
        BytesPerPixel
        BitsPerPixel
        FrameBytesOnDisk
        Geometry
        FrameRate
        BitsArePacked
        Endianness
        FrameCount
        SensorOffset
        SensorSize
        ClockSpeed
        ExposureMS
        Gain
        SystemID
    end

    properties(Hidden,Access=protected)
        fid  
    end

    %% PROTECTED
    methods(Access=protected)
        function str = readString(obj)
            n = fread(obj.fid, 1, 'uint32');
            str = fread(obj.fid,n,'char');
            fread(obj.fid,1,'uint8'); % trainling 0
            str = char([str']);
        end

        function readHeader(obj)
            %READHEADER         Read CCV header information.

            header_size = fread(obj.fid, 1, 'uint32');

            obj.Camera = obj.readString();
            obj.Version = fread(obj.fid,1,'double');

            if (obj.Version < 0.12) || (obj.Version > 0.2)
                error("ANA:video:ccv:invalidVersion", "Unsupported version: %g", obj.Version)
            end
            
            obj.ImageType = obj.readString();
                
            obj.BytesPerPixel = fread(obj.fid,1,'uint32');
            obj.BitsPerPixel = fread(obj.fid,1,'uint32');
            obj.FrameBytesOnDisk = fread(obj.fid,1,'uint32');
            obj.Geometry = fread(obj.fid,2,'uint32');
            obj.FrameRate = fread(obj.fid,1,'double');

            if obj.Version >= 0.13
                obj.BitsArePacked = fread(obj.fid,1,'uint8');
                if obj.Version >= 0.2
                    obj.Endianness = fread(obj.fid,1,'uint8');
                    fread(obj.fid,2,'uint8'); % reserved for future use
                end
            end

            obj.FrameCount = fread(obj.fid,1,'double');

            if obj.Version >= 0.13
                obj.SensorOffset = fread(obj.fid,2,'uint32');
                obj.SensorSize = fread(obj.fid,2,'uint32');
                obj.ClockSpeed = fread(obj.fid,1,'uint64');
                obj.ExposureMS = fread(obj.fid,1,'double');
                obj.Gain = fread(obj.fid,1,'double');

                if obj.Version >= 0.20
                    obj.SystemID = obj.readString();
                end
            end

            if obj.Version >= 0.20
                fseek(obj.fid,header_size,"bof");
            end
        end
    end

    %% PUBLIC
    methods
        function obj = ccv(filename)
            %CCV    Construct an instance of this class.
            arguments
                filename = []
            end

            if ~isempty(filename)
                obj.open(filename);
            end
        end

        function delete(obj)
            %DELETE  Destruct instance of this class.
            try fclose(obj.fid); catch, end
        end

        function obj = open(obj,filename)
            %OPEN       Open a CCV file for reading frames.
            arguments
                obj ana.video.ccv
                filename string
            end

            fpath = ana.fs.path(filename);
            fpath = fpath.resolve();
            if isempty(fpath)
                error("ANA:file:fileNotFound", "Could not find file: %s", string(filename))
            end
            obj.FilePath = fpath;

            obj.fid = fopen(string(fpath), "rb");
            obj.readHeader();
        end

        function res = eof(obj)
            %EOF    Check if end-of-file was reached.
            res = feof(obj.fid);
        end

        function [frame,hdr] = read(obj)
            %READ   Read next frame.

            % image data
            geom = [obj.Geometry(2) obj.Geometry(1) obj.BytesPerPixel];
            frame = fread(obj.fid,prod(geom),'uint8=>uint8');
            if obj.BitsPerPixel ~= 8
                FIXME("check packing, etc.")
            end
            
            frame = reshape(frame,[obj.Geometry(1) obj.Geometry(2) obj.BytesPerPixel]);

            % tail info
            hdr = struct();
            if obj.Version >= 0.13
                hdr.Index = fread(obj.fid,1,'uint32');
                hdr.ComputerTime = fread(obj.fid,1,'double');

                if obj.Version >= 0.20
                    hdr.CameraTime = fread(obj.fid,1,'uint64');
                    hdr.Flags = fread(obj.fid,1,'uint32');
                else
                    switch (obj.Camera)
                        case 'Aptina'
                            % no more
                            hdr.CameraTime = [];
                            hdr.Flags = [];
                        case 'Basler'
                            hdr.CameraTime = fread(obj.fid,1,'uint64');
                            hdr.Flags = fread(obj.fid,1,'uint8');
                    end
                end
            end
        end
    end
end
% Copyright (C) 2026 MPI f. Neurobiol. of Behavior — caesar
% SPDX-License-Identifier: GPL-3.0-or-later
% Author(s):
%   Jürgen "George" Sawinski
%
