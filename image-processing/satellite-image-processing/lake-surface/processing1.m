
img = imread('src/osirid_lake_4K_bright+contrast.jpg');

water = segment_water(img);
water = water.*1.4;             %brightness gain

gray = rgb2gray(water);

hsv = rgb2hsv(water);

ycybcr = rgb2ycbcr(water);


temp1 = hsv(:,:,3);
temp2 = ycybcr(:,:,1);


figure(1)
imshow(temp1)

figure(2)
imshow(temp2)