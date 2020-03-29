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

MyLaneAngleLimit = 60;
SideLaneAngleLimit = 80;


frameFilter = FrameSequnceFilter(FrameFilterOrder, FrameFilterPeriod);

myLaneLeftLineManager = HoughLinesManager();
myLaneRightLineManager = HoughLinesManager();
rightLaneRightLineManager = HoughLinesManager();
leftLaneLeftLineManager = HoughLinesManager();


% while ~isDone(videoReader)
% for frameCounter=1:videoReader.NumFrames
for frameCounter = 1:20
    frameCounter
    traffic = videoReader();
    traffic = imresize(traffic, FrameResizeScale);
    
    if(FrameResizeScale == 0.5)
        yOffsetLow = 90; yOffsetHigh = 260;
        xOffsetLow = 60; xOffsetHigh = 580;
        road = traffic(yOffsetLow:yOffsetHigh,60:580,:);
    elseif (FrameResizeScale == 0.25)
        yOffsetLow = 45; yOffsetHigh = 130;
        xOffsetLow = 1;  xOffsetHigh = 580/2;
        road = traffic(yOffsetLow:yOffsetHigh,1:end,:);
    else 
        disp('Error');
    end
     
    % Edges and filtering
    %edges = edge(rgb2gray(road), 'canny', 0.4);
    edges = edge(rgb2gray(road), 'sobel');
    
    if(frameCounter == 1)
        ignoreMask = createIgnoreMask(edges);
    end
    
    edges = edges & ignoreMask;
    edges = edges | frameFilter.update(edges);

    

    
    % Hough transform
    [H,T,R] = hough(edges,'RhoResolution',0.5,'Theta',[-80:0.5:-10 10:0.5:80]);
    P  = houghpeaks(H,8,'threshold',ceil(0.3*max(H(:))));
    lines = houghlines(edges,T,R,P,'FillGap',300,'MinLength',60);

    
    idl = 0;
    idr = 0;
    idrs = 0;
    idls = 0;
    clear myLeftLines
    clear myRightLines
    clear sideRightLines
    clear sideLeftLines
    
    for k = 1:length(lines)
        if DebugEnabled == 1
            xy = [lines(k).point1; lines(k).point2];
            plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
%             plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%             plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
        end
        
        if(lines(k).theta < MyLaneAngleLimit && lines(k).theta > 0)
            idl = idl +1;
            myLeftLines(idl) = lines(k);
            length(myLeftLines);

        elseif(lines(k).theta > -MyLaneAngleLimit && lines(k).theta < 0)
            idr = idr+1;
            myRightLines(idr) = lines(k);
            length(myRightLines);
            
        elseif(lines(k).theta > -SideLaneAngleLimit && lines(k).theta < MyLaneAngleLimit)
            idrs = idrs+1;
            sideRightLines(idrs) = lines(k);
            length(sideRightLines);
        elseif(lines(k).theta < SideLaneAngleLimit && lines(k).theta > MyLaneAngleLimit)
            idls = idls +1;
            sideLeftLines(idls) = lines(k);
            length(sideLeftLines);
        end
    end
    
    if DebugEnabled == 0
        if(idl > 0)
            myLaneLeftLineManager.set(myLeftLines);
        else
            myLaneLeftLineManager.lastSet();
        end    
        [lp1, lp2] = myLaneLeftLineManager.pointsAverageByModule(10);
        [lp1, lp2] = myLaneLeftLineManager.resizeLineOnScreen(edges, lp1, lp2);

            
        if(idr > 0)
            myLaneRightLineManager.set(myRightLines);
        else 
            myLaneRightLineManager.lastSet();
        end
        [rp1, rp2] = myLaneRightLineManager.pointsAverageByModule(10);
        [rp1, rp2] = myLaneRightLineManager.resizeLineOnScreen(edges, rp1, rp2);
        
        
        if(idrs > 0)
            rightLaneRightLineManager.set(sideRightLines);
        else 
            rightLaneRightLineManager.lastSet();
        end
        [srp1, srp2] = rightLaneRightLineManager.pointsAverageByModule(10);
        [srp1, srp2] = rightLaneRightLineManager.resizeLineOnScreen(edges, srp1, srp2);
        
        
                
        if(idls > 0)
            leftLaneLeftLineManager.set(sideLeftLines);
        else 
            leftLaneLeftLineManager.lastSet();
        end
        [slp1, slp2] = leftLaneLeftLineManager.pointsAverageByModule(10);
        [slp1, slp2] = leftLaneLeftLineManager.resizeLineOnScreen(edges, slp1, slp2);
    end
    

        
    myLaneMask = createLaneMaskWithOffset(traffic, lp1, lp2, rp1, rp2, xOffsetLow, yOffsetLow);
    rightLaneMask = createLaneMaskWithOffset(traffic, rp1, rp2, srp1, srp2, xOffsetLow, yOffsetLow);
    leftLaneMask = createLaneMaskWithOffset(traffic, lp1, lp2, slp1, slp2, xOffsetLow, yOffsetLow);
  
    ColorIntensity = 50;
    traffic(:,:,3) = traffic(:,:,3) + (rightLaneMask).*ColorIntensity/255;
    traffic(:,:,3) = traffic(:,:,3) + (leftLaneMask).*ColorIntensity/255;
    traffic(:,:,2) = traffic(:,:,2) + (myLaneMask).*ColorIntensity/255;
    

    
    figure(1)
    imshowpair(traffic,edges, 'montage'); hold on;
    xy = [rp2; rp1];
    plot(xy(:,1)+xOffsetLow,xy(:,2)+yOffsetLow,'LineWidth',2,'Color','green');
    xy = [lp1; lp2];
    plot(xy(:,1)+xOffsetLow,xy(:,2)+yOffsetLow,'LineWidth',2,'Color','green');
    xy = [srp2; srp1];
    plot(xy(:,1)+xOffsetLow,xy(:,2)+yOffsetLow,'LineWidth',2,'Color','blue');
    xy = [slp2; slp1];
    plot(xy(:,1)+xOffsetLow,xy(:,2)+yOffsetLow,'LineWidth',2,'Color','blue');
    
end




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


function mask = createLaneMask(frame, lp1, lp2, rp1, rp2)

    [ySize,xSize,cSize] = size(frame);

    yOffset = 45;
    
    x = [lp1(1) rp1(1) rp2(1) lp2(1)];
    y = [lp1(2)+yOffset rp1(2)+yOffset rp2(2)+yOffset lp2(2)+yOffset];
    mask = poly2mask(x,y,ySize,xSize);
    
%     figure(6)
%     imshow(mask)
end

function mask = createLaneMaskWithOffset(frame, lp1, lp2, rp1, rp2, xOffset, yOffset)

    [ySize,xSize,cSize] = size(frame);
    
    x = [lp1(1)+xOffset rp1(1)+xOffset rp2(1)+xOffset lp2(1)+xOffset];
    y = [lp1(2)+yOffset rp1(2)+yOffset rp2(2)+yOffset lp2(2)+yOffset];
    mask = poly2mask(x,y,ySize,xSize);
    
%     figure(6)
%     imshow(mask)
end
