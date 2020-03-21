if isunix
    videoReader = VideoReader('tennis_ball_motion.ogv')
elseif ispc
    videoReader = VideoReader('tennis_ball_motion.avi')
end


videoWriter = VideoWriter('tennis_ball_tracked_by_shape')
videoWriter.FrameRate = 15;
open(videoWriter);


[xSize,ySize,cSize]=size(rgb2hsv(readFrame(videoReader)));


BallDiameter = 24;
BallRadius = 12;
 


while hasFrame(videoReader)
    frame = (readFrame(videoReader));

     [centers, radii] = imfindcircles(frame,[10 20], ...
         'ObjectPolarity','dark','Sensitivity',0.9,'EdgeThreshold',0.1);
     

    if centers
        x = centers(1);
        y = centers(2);

        if(x >25 && y > 25)
            objectImage = insertShape(frame,'Rectangle',[(x-25) (y-25) 50 50],'Color','red');
            objectImage = insertShape(objectImage,'Circle',[x y radii(1)],'Color','cyan');
            objectImage = insertText(objectImage,[x-20, y-50],'Target','BoxOpacity',0.1,'BoxColor','red');
            imshow(objectImage, [])
        end
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
