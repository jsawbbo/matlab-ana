files = ["./M260312DB01_20260530/M260312DB01_20260530_EyeCam010001.raw",...
    "./M260316DB02_20260529/EyeCam_010000.raw", ...
    "./M260309DB01_20260530/M260309DB01_20260530_EyeCam010000.raw"];

width = 752;
height = 480;

left = 330;
right = 753-left;

for k = 1:3
    f = fopen(files(k));
    
    while ~feof(f)
        I = readframe(f,width,height);

        L = I(1:left,:);
        R = I(right:end,:);

        L = imadjust(L);
        R = imadjust(R);

        imshowpair(L',R',"montage");
        pause(0.0001)
    end

end

function I = readframe(f,width,height)
    I = fread(f,[width,height],'uint8=>uint8');
end