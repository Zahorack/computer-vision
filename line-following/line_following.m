close all;
% clear all;

if isunix
    videoReader = vision.VideoFileReader('traffic.ogv')
elseif ispc
    videoReader = vision.VideoFileReader('traffic.mp4')
end


set(gcf, 'DoubleBuffer', 'on');

% Constants
FrameFilterOrder = 2;
FrameFilterPeriod = 5;
FrameResizeScale = 0.25;

KalmanFilterQ = 0.025;
KalmanFilterR = 1.5;

MyLaneAngleLimit = 60;

frameFilter = FrameSequnceFilter(FrameFilterOrder, FrameFilterPeriod);

kalmanPoint1 =  KalmanFilterForPoint(KalmanFilterQ, KalmanFilterR);
kalmanPoint2 =  KalmanFilterForPoint(KalmanFilterQ, KalmanFilterR);
kalmanPoint3 =  KalmanFilterForPoint(KalmanFilterQ, KalmanFilterR);
kalmanPoint4 =  KalmanFilterForPoint(KalmanFilterQ, KalmanFilterR);

leftLineManager = HoughLinesManager();
rightLineManager = HoughLinesManager();

% while ~isDone(videoReader)
% for frameCounter=1:videoReader.NumFrames
for frameCounter = 1:2
    frameCounter
    traffic = videoReader();
    traffic = imresize(traffic, FrameResizeScale);
    
    if(FrameResizeScale == 0.5)
        road = traffic(90:260,60:580,:);
    elseif (FrameResizeScale == 0.25)
         road = traffic(45:130,1:end,:);
    else 
        disp('Error');
    end
      
%     edges = edge(rgb2gray(road), 'canny', 0.4);
    edges = edge(rgb2gray(road), 'sobel', 0.1);
    
    if(frameCounter == 1)
        ignoreMask = createIgnoreMask(edges);
        
    end
    edges = edges & ignoreMask;
    
    edges = edges | frameFilter.update(edges);

    figure(1)
    imshowpair(road,edges, 'montage'); hold on;
    
    
    [H,T,R] = hough(edges,'RhoResolution',1,'Theta',[-80:1:-10 10:1:80]);
    
    P  = houghpeaks(H,12,'threshold',ceil(0.3*max(H(:))));

    
    lines = houghlines(edges,T,R,P,'FillGap',400,'MinLength',70);
    
    max_len = 0;
    idl = 0;
    idr = 0;
    clear myLeftLines
    clear myRightLines
    for k = 1:length(lines)
  
%         xy = [lines(k).point1; lines(k).point2];
%         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
%         plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%         plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
        
        if(lines(k).theta < MyLaneAngleLimit && lines(k).theta > 0)
            idl = idl +1;
            myLeftLines(idl) = lines(k);
            length(myLeftLines);

        elseif(lines(k).theta > -MyLaneAngleLimit && lines(k).theta < 0)
            idr = idr+1;
            myRightLines(idr) = lines(k);
            length(myRightLines);
        end
    end
    
    if(idl > 0)
        leftLineManager.set(myLeftLines);
        [p2, p1] = leftLineManager.statisticsPoints();
        p1 = kalmanPoint1.update(p1);
        p2 = kalmanPoint2.update(p2);
        
        [p2, p1] = rightLineManager.resizeLineOnScreen(edges, p1, p2);
        
        xy = [p1; p2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
    
    
    if(idr > 0)
        rightLineManager.set(myRightLines);
        [p2, p1] = rightLineManager.statisticsPoints();
        p1 = kalmanPoint3.update(p1);
        p2 = kalmanPoint4.update(p2);
        
        xy = [p2; p1];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end

    
end

clear edges



function mask = createIgnoreMask(frame)
    [ySize,xSize,cSize] = size(frame);
    
    mask = ones(ySize,xSize,1);
    
    xLimit = round(xSize/3);
    yLimit = round(ySize/3);

    c = [0  xLimit   0]; 
    r = [0  0        yLimit];
    mask1 = poly2mask(c,r,ySize,xSize);
    
    c = [xSize-xLimit   xSize   xSize]; 
    r = [0              0       yLimit];
    mask2 = poly2mask(c,r,ySize,xSize);
    
    mask = ~(mask1 | mask2);
    
%     figure(3)
%     imshow(mask)
end




