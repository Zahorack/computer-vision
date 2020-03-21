if isunix
    videoReader = VideoReader('tennis_ball_motion.ogv')
elseif ispc
    videoReader = VideoReader('tennis_ball_motion.avi')
end

hsvframe = HsvFrame;
hsvmask = HsvFrame;
    
videoWriter = VideoWriter('tennis_ball_tracked_by_color')
videoWriter.FrameRate = 15;
open(videoWriter);

HueHigh = 90/255;
HueLow = 40/255;
SaturationHigh = 230/255;
SaturationLow = 30/255;
ValueHigh = 250/255;
ValueLow = 10/255;

[xSize,ySize,cSize]=size(rgb2hsv(readFrame(videoReader)));
segment = zeros(xSize,ySize,cSize); 


while hasFrame(videoReader)
    frame = readFrame(videoReader);
    hsvframe.update(rgb2hsv(frame));
    

    hsvmask.hue(bin_segmentation(hsvframe.hue(), HueLow, HueHigh));
    hsvmask.saturation(bin_segmentation(hsvframe.saturation(), SaturationLow, SaturationHigh));
    hsvmask.value(bin_segmentation(hsvframe.value(), ValueLow, ValueHigh));
    
    
    mask1 = (hsvmask.hue() & hsvmask.saturation()  & hsvmask.value());
    
    %erosion/dilation
    se = strel('disk',10);
    mask2=imclose(mask1,se);
    
    %colorize segmentation 
    frame(:,:,2) = frame(:,:,2) + uint8(mask2).*100;

    
    
     [x,y] = centerOfMass(mask1);
     if(x >25 && y > 25)
         objectImage = insertShape(frame,'Rectangle',[(x-25) (y-25) 50 50],'Color','red');
         objectImage = insertText(objectImage,[x-20, y-50],'Target','BoxOpacity',0.1,'BoxColor','red');
         imshow(objectImage, [])
     end
    
    writeVideo(videoWriter, objectImage);
end

close(videoWriter)



function mask = bin_segmentation(frame, low, high)
    mask = frame > low & frame < high;
end

function [xcentre, ycentre] = centerOfMass(img)
    [x, y] = meshgrid(1:size(img, 2), 1:size(img, 1));
    weightedx = x .* img;
    weightedy = y .* img;
    xcentre = round(sum(weightedx(:)) / sum(img(:)));
    ycentre = round(sum(weightedy(:)) / sum(img(:)));
end
