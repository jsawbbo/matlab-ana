function [res] = opticflow(folder,options)
    %ANA.TOOL.OPTICALFLOW Summary of this function goes here
    %
    %   Detailed explanation goes here
    %

    arguments (Input)
        folder (1,1) string = ''
        options.Mask = []
        options.Frames = []
    end

    % arguments (Output)
    %     outputArg1
    %     outputArg2
    % end

    imds = imageDatastore(folder);

    if isempty(options.Frames)
        frames = [1,numel(imds.Files)];
    else
        frames = options.Frames;
    end

    % prepare dimensions
    img = readimage(imds,1);
    dim = size(img,[1 2]);
    crop = [1,dim(1),1,dim(2)]; 

    if ~isempty(options.Mask)
        [~,~,mask] = imread(options.Mask);
        mask = mask/255;

        % re-calculate "crop"
        a = sum(mask, 2);
        crop(1) = find(a > 0, 1, 'first');
        crop(2) = find(a > 0, 1, 'last');

        b = sum(mask,1);
        crop(3) = find(b > 0, 1, 'first');
        crop(4) = find(b > 0, 1, 'last');

        mask = mask(crop(1):crop(2), crop(3):crop(4));
    else
        mask = ones(dim(:));
    end

    opticFlow = opticalFlowFarneback('NumPyramidLevels', 3);
    % opticFlow = opticalFlowHS;

    h = figure;
    movegui(h);
    hViewPanel = uipanel(h,Position=[0 0 1 1],Title="Plot of Optical Flow Vectors");
    hPlot = axes(hViewPanel);
    for idx = frames(1):frames(2)
        [img,~] = readimage(imds,idx);

        frameRGB = img(crop(1):crop(2), crop(3):crop(4));
        frameGray = im2gray(frameRGB) .* mask;  

        flow = estimateFlow(opticFlow,frameGray);
        imshow(frameRGB)
        hold on
        plot(flow,DecimationFactor=[20 20],ScaleFactor=5,Parent=hPlot);
        hold off
        pause(10^-3)
    end
end