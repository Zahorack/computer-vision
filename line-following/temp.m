close all

if isunix
    videoReader = VideoReader('traffic.ogv')
elseif ispc
    videoReader = VideoReader('traffic.mp4')
end


set(gcf, 'DoubleBuffer', 'on');



while(hasFrame(videoReader))
    
    traffic = readFrame(videoReader);
    
    traffic = imresize(traffic, 0.25);

    road = traffic(40:120,:,:);
    % imshow(road);


     edges = edge(rgb2gray(road), 'canny');
%     edges = edge(rgb2gray(road), 'sobel');
     figure(1)
     imshow(edges)


    [H,T,R] = hough(edges,'RhoResolution',0.5,'Theta',-80:0.5:80);


    P  = houghpeaks(H,10,'threshold',ceil(0.3*max(H(:))));
    % x = T(P(:,2)); y = R(P(:,1));
    % plot(x,y,'s','color','white');


    lines = houghlines(edges,T,R,P,'FillGap',100,'MinLength',50);
    
    figure(2), imshow(road), hold on

%   imshowpair(road, edges, 'montage')

    max_len = 0;
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

       % Determine the endpoints of the longest line segment
       len = norm(lines(k).point1 - lines(k).point2);
       if ( len > max_len)
          max_len = len;
          xy_long = xy;
       end
    end
    
end