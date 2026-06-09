classdef imageseq < handle
    %ana.media.imageseq     Image sequence (sequence, stack or video).
    %
    %   FIXME
    %

    properties(SetAccess=protected)
        Type = 'any'        % Image store type ('sequence', 'stack', 'timeseries')
        Frames = []         % Frame counter (may have gaps).
        Time = []           % Frame time (if applicable).
        Position = []       % Frame position (if applicable).
    end

    properties(Hidden,SetAccess=protected)
        Store
        Cache 
    end

    methods
        function obj = imageseq(options)
            %IMAGESEQ Construct an instance of this class
            arguments
                options.Cache = '/tmp'
            end

            obj.Cache = ana.fs.path(options.Cache);
        end

        function obj = load(obj,pathname)
            %LOAD   Load video or image store.

            pathname = ana.fs.path(pathname);
            if isfolder(pathname)
                FIXME()
            else
                [~,~,ext] = fileparts(pathname);
                ext = lower(ext);

                switch (ext)
                    case '.mp4'
                end
            end
        end
    end
end