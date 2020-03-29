# Lane departure warning system

Matlab computer vision - line following project

### Original video
![](https://github.com/Zahorack/computer-vision/blob/master/line-following/animations/gifs/original.gif)

### Edges identification

First for better computing speed I have decrease resolution of every single frame. Then I resized camera 
view from car to road view only and applied matlab edge filter

```edges = edge(rgb2gray(road), 'sobel');```

<img src="https://github.com/Zahorack/computer-vision/blob/master/line-following/animations/gifs/lane_following_raw_edges.gif" width="512">


### Ignore mask for not interesting spaces
Another modification is creating and applying ignore mask on the left and the right upper corner.

```edges = edges & ignoreMask;```


<img src="https://github.com/Zahorack/computer-vision/blob/master/line-following/animations/gifs/lane_following_edges_ignore_mask.gif" width="512">

### Frame sequence filtering

I have created [FrameSequenceFilter](https://github.com/Zahorack/computer-vision/blob/master/line-following/FrameSequnceFilter.m)
object to reach better edges line representation. Usage:

```
frameFilter = FrameSequnceFilter(FrameFilterOrder, FrameFilterPeriod);
```

Variable `` FrameFilterOrder `` set order of filter, it is size of filter Queue buffer. `` FrameFilterPeriod`` set period 
in frames to take new image to filter queue and erase last one.

```
edges = edges | frameFilter.update(edges);
```

<img src="https://github.com/Zahorack/computer-vision/blob/master/line-following/animations/gifs/lane_following_edges_frame_sequence_filter.gif" width="512">


### Hough transform line detecting
I have used inter matlab Hough transform algorithm to find lines from prepared edges.

```
[H,T,R] = hough(edges,'RhoResolution',0.5,'Theta',[-80:0.5:-10 10:0.5:80]);
P  = houghpeaks(H,8,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(edges,T,R,P,'FillGap',300,'MinLength',60);
```
    
<img src="https://github.com/Zahorack/computer-vision/blob/master/line-following/animations/gifs/lane_following_detected_lines.gif" width="512">

For better handling and preocessing with lines I have created [HoughLinesManager.m](https://github.com/Zahorack/computer-vision/blob/master/line-following/HoughLinesManager.m)
object. 

I had multiple problem with detected lines, they ere changing polarity, position and size. So i have to implement stastics and others features. 

```
[lp1, lp2] = myLaneLeftLineManager.pointsAverageByModule(10);
[lp1, lp2] = myLaneLeftLineManager.resizeLineOnScreen(edges, lp1, lp2);
```
I have fix lines polaritywith soting method based on point module in 2D space. Resizing Lines on whole screen space i did with 
straight line equation aproximation.

I have also used custom [KalmanFilter](https://github.com/Zahorack/computer-vision/blob/master/line-following/KalmanFilter.m) object for smoothing
lines changing.

### Lane departure warning system

Finally I have visualised lines, lanes and warning when lane departure was detected.

<img src="https://github.com/Zahorack/computer-vision/blob/master/line-following/animations/gifs/lane_departure_warning.gif" width="512">
