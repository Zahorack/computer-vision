
# Image segmentation and object tracking
Matlab image processing implementation

### Original video
![](https://github.com/Zahorack/computer-vision/blob/master/image-processing/segmentation/animations/tennis_ball_motion.gif)

### Segmentation by color

We are processing segmentation in HSV color format

```
    frame = rgb2hsv(readFrame(videoReader));
```

Object ``HsvTresholds`` hold  values for thresholding segmentation
```
tresholds = HsvTresholds;

tresholds.HueHigh = 90/255;
tresholds.HueLow = 40/255;
tresholds.SaturationHigh = 230/255;
tresholds.SaturationLow = 30/255;
tresholds.ValueHigh = 250/255;
tresholds.ValueLow = 10/255;
```

We have implemented object ``SegmentaionByColor`` which constructor parameter is already HsvTresholds object

```
segmentation = SegmentaionByColor(tresholds);

binMask = segmentation.binary(frame);
```

Method ``segmentation.binary(frame)`` return binary array or mask based on detected pixels in tresholding interval for HSV color spectrum.

From the mask we can now compute center of mass and track color object. Optionally we can use Erosion or Dilation for better results.

Function ``segmentation.binary(frame)`` do matrix comparison for all 3 HSV dimensions - Hue, Saturation and Value. Sometimes enough to compare only 
first Hue spectrum and save computation power.

![](https://github.com/Zahorack/computer-vision/blob/master/image-processing/segmentation/animations/tennis_ball_tracked_by_color.gif)


### Segmentation by shape

Segmentation by shape, specifically by circle, we will implement in matlab with function ``imfindcircles``

```
[centers, radii] = imfindcircles(frame,[(BallRadius-2) (BallRadius+8)], 'ObjectPolarity','dark','Sensitivity',0.9,'EdgeThreshold',0.1);
```

![](https://github.com/Zahorack/computer-vision/blob/master/image-processing/segmentation/animations/tennis_ball_tracked_by_shape.gif)


### Segmentation by color shape

Now we merge both segmentation method to reach the best solution.

Method ``imfindcircles`` returns coordinates and radius of found circle shape. With these values we create new ``MergeMask``

```
        [I,J] = ndgrid(1:xFrameSize,1:yFrameSize);
        MergeMask = double((I-centers(2)).^2+(J-centers(1)).^2 <= radii(1)^2);
        binMask = binMask & MergeMask;
```


![](https://github.com/Zahorack/computer-vision/blob/master/image-processing/segmentation/animations/tennis_ball_tracked_by_color_and_shape.gif)
