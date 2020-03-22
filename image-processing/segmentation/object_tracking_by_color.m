if isunix
    videoReader = VideoReader('tennis_ball_motion.ogv')
elseif ispc
    videoReader = VideoReader('tennis_ball_motion.avi')
end

    
videoWriter = VideoWriter('animations/tennis_ball_tracked_by_color')
videoWriter.FrameRate = 15;
open(videoWriter);


tresholds = HsvTresholds;

tresholds.HueHigh = 90/255;
tresholds.HueLow = 40/255;
tresholds.SaturationHigh = 230/255;
tresholds.SaturationLow = 30/255;
tresholds.ValueHigh = 250/255;
tresholds.ValueLow = 10/255;


segmentation = SegmentaionByColor(tresholds);


while hasFrame(videoReader)
    
    frame = readFrame(videoReader);
    
    binMask = segmentation.binary(rgb2hsv(frame));

    %erosion/dilation
    se = strel('disk',10);
    binMask = imclose(binMask,se);

    %colorize segmentation 
    frame(:,:,2) = frame(:,:,2) + uint8(binMask).*100;

      
    [x,y] = centerOfMass(binMask);
    if(x >25 && y > 25)
        objectImage = insertShape(frame,'Rectangle',[(x-25) (y-25) 50 50],'Color','red');
        objectImage = insertText(objectImage,[x-20, y-50],'Target','BoxOpacity',0.1,'BoxColor','red');
        imshow(objectImage, [])
        writeVideo(videoWriter, objectImage);
    end
    
    
end

close(videoWriter)


function [xcentre, ycentre] = centerOfMass(img)
    [x, y] = meshgrid(1:size(img, 2), 1:size(img, 1));
    weightedx = x .* img;
    weightedy = y .* img;
    xcentre = round(sum(weightedx(:)) / sum(img(:)));
    ycentre = round(sum(weightedy(:)) / sum(img(:)));
end
