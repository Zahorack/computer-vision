close all;
% clear all;

if isunix
    videoReader = vision.VideoFileReader('traffic.ogv')
elseif ispc
    videoReader = vision.VideoFileReader('traffic.mp4')
end


set(gcf, 'DoubleBuffer', 'on');


% Development
DebugEnabled = 0;

% Constants
FrameFilterOrder = 3;
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
for frameCounter = 1:130
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
     
    % Edges and filtering
    %edges = edge(rgb2gray(road), 'canny', 0.4);
    edges = edge(rgb2gray(road), 'sobel', 0.1);
    
    if(frameCounter == 1)
        ignoreMask = createIgnoreMask(edges);
    end
    
    edges = edges & ignoreMask;
    edges = edges | frameFilter.update(edges);

    

    
    % Hough transform
    [H,T,R] = hough(edges,'RhoResolution',0.5,'Theta',[-80:0.5:-10 10:0.5:80]);
    P  = houghpeaks(H,10,'threshold',ceil(0.3*max(H(:))));
    lines = houghlines(edges,T,R,P,'FillGap',300,'MinLength',60);

    
    idl = 0;
    idr = 0;
    clear myLeftLines
    clear myRightLines
    
    for k = 1:length(lines)
        if DebugEnabled == 1
            xy = [lines(k).point1; lines(k).point2];
            plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
            plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
            plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
        end
        
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
    
    if DebugEnabled == 0
        if(idl > 0)
            leftLineManager.set(myLeftLines);
        else
            leftLineManager.lastSet();
        end    
        [lp1, lp2] = leftLineManager.pointsAverageByModule(10)
        lp1 = kalmanPoint1.update(lp1);
        lp2 = kalmanPoint2.update(lp2);
        [lp1, lp2] = leftLineManager.resizeLineOnScreen(edges, lp1, lp2);

            
        if(idr > 0)
            rightLineManager.set(myRightLines);
        else 
            rightLineManager.lastSet();
        end
        [rp1, rp2] = rightLineManager.pointsAverageByModule(10);
        rp1 = kalmanPoint3.update(rp1);
        rp2 = kalmanPoint4.update(rp2);
        [rp1, rp2] = rightLineManager.resizeLineOnScreen(edges, rp1, rp2);
    end
    
    
    laneMask = createLaneMask(road, lp1, lp2, rp1, rp2);
    road(:,:,3) = road(:,:,3) + (laneMask).*5;
    
    figure(1)
    imshowpair(road,edges, 'montage'); hold on;
    xy = [rp2; rp1];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    xy = [lp1; lp2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
end




function mask = createIgnoreMask(frame)
    [ySize,xSize,cSize] = size(frame);
    
    mask = ones(ySize,xSize,1);
    
    xLimit = round(xSize/2);
    yLimit = round(ySize/1.5);

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


function mask = createLaneMask(frame, lp1, lp2, rp1, rp2)

    [ySize,xSize,cSize] = size(frame);
    
    x = [lp1(1) rp1(1) rp2(1) lp2(1)];
    y = [lp1(2) rp1(2) rp2(2) lp2(2)];
    mask = poly2mask(x,y,ySize,xSize);
    
%     figure(6)
%     imshow(mask)
end

