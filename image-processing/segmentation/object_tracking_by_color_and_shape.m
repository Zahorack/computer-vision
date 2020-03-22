if isunix
    videoReader = VideoReader('tennis_ball_motion.ogv')
elseif ispc
    videoReader = VideoReader('tennis_ball_motion.avi')
end

[xSize,ySize,cSize] = size((readFrame(videoReader)));

videoWriter = VideoWriter('animations/tennis_ball_tracked_by_color_and_shape')
videoWriter.FrameRate = 15;
open(videoWriter);

% Config segmentation by color
tresholds = HsvTresholds;
tresholds.HueHigh = 90/255;
tresholds.HueLow = 40/255;
tresholds.SaturationHigh = 230/255;
tresholds.SaturationLow = 30/255;
tresholds.ValueHigh = 250/255;
tresholds.ValueLow = 10/255;

% Config segmentation by shape
BallRadius = 12;

% Segmentation by HSV color object
segmentation = SegmentaionByColor(tresholds);


while hasFrame(videoReader)
    frame = readFrame(videoReader);
   
    binMask = segmentation.binary(rgb2hsv(frame));
    
    % Erosion
    se = strel('disk',10);
    binMask = imclose(binMask,se);
    

    %segmentation by shape
    [centers, radii] = imfindcircles(frame,[(BallRadius-2) (BallRadius+8)], ...
        'ObjectPolarity','dark','Sensitivity',0.9,'EdgeThreshold',0.1);
    
      
    if centers
        x = centers(1);
        y = centers(2);
        r = radii;
        
        % Merge segmentation by color and shape
        [I,J] = ndgrid(1:xSize,1:ySize);
        MergeMask = double((I-y).^2+(J-x).^2 <= radii(1)^2);
        binMask = binMask & MergeMask;
        

        %colorize segmentation 
        frame(:,:,2) = frame(:,:,2) + uint8(binMask).*100;

        if(x >25 && y > 25)
            % Tracking visualisation
            objectImage = insertShape(frame,'Rectangle',[(x-r(1)*2) (y-r(1)*2) r(1)*4 r(1)*4],'Color','red');
            objectImage = insertShape(objectImage,'Circle',[x y radii(1)],'Color','cyan');
            objectImage = insertText(objectImage,[x-20, y-50],'Target','BoxOpacity',0.1,'BoxColor','red');
            imshow(objectImage, [])
            
            writeVideo(videoWriter, objectImage);
        end
    end
    
end

close(videoWriter)
