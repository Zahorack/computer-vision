if isunix
    videoReader = VideoReader('tennis_ball_motion.ogv')
elseif ispc
    videoReader = VideoReader('tennis_ball_motion.avi')
end

videoWriter = VideoWriter('animations/tennis_ball_tracked_by_shape')
videoWriter.FrameRate = 15;
open(videoWriter);

BallRadius = 12;


while hasFrame(videoReader)
    frame = (readFrame(videoReader));

     [centers, radii] = imfindcircles(frame,[(BallRadius-2) (BallRadius+8)], ...
         'ObjectPolarity','dark','Sensitivity',0.9,'EdgeThreshold',0.1);
     

    if centers
        x = centers(1);
        y = centers(2);

        if(x >25 && y > 25)
            % Tracking visualisation
            objectImage = insertShape(frame,'Rectangle',[(x-25) (y-25) 50 50],'Color','red');
            objectImage = insertShape(objectImage,'Circle',[x y radii(1)],'Color','cyan');
            objectImage = insertText(objectImage,[x-20, y-50],'Target','BoxOpacity',0.1,'BoxColor','red');
            imshow(objectImage, [])
            
            writeVideo(videoWriter, objectImage);
        end
    end
    
    
end

close(videoWriter)

