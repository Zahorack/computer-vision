close all

template = imread ('objects/stopka.bmp');
traffic = imread('objects/street2.bmp');

% Surf signs of template
template_gray = rgb2gray(template);
template_surf = detectSURFFeatures(template_gray);
[template_features, template_validPts] = extractFeatures(template_gray, template_surf);

% figure(1); 
% imshow(template);
% hold on;
% plot(selectStrongest(template_surf,20));

% Surf signs of traffic
traffic_gray = rgb2gray(traffic);
traffic_surf = detectSURFFeatures(traffic_gray); 
[traffic_features, traffic_validPts] = extractFeatures(traffic_gray,traffic_surf); 


% figure(2); 
% imshow(traffic);
% hold on; 
% plot(selectStrongest(traffic_surf,100));


index_pairs = matchFeatures (template_features, traffic_features);

template_matched_pts = template_validPts(index_pairs(:,1)).Location;
traffic_matched_pts = traffic_validPts(index_pairs(:,2)).Location;


% figure(3);
% showMatchedFeatures(traffic_gray, template_gray, traffic_matched_pts, template_matched_pts)

% figure;
% showMatchedFeatures(traffic_gray, template_gray, traffic_matched_pts, template_matched_pts,'blend')
% 
% figure;
% showMatchedFeatures(traffic_gray, template_gray, traffic_matched_pts, template_matched_pts,'montage')


% geometric transforamtion estimation
[tform, R_inlier_pts, I_inlier_pts] = estimateGeometricTransform(template_matched_pts, traffic_matched_pts, 'affine');

% figure(4);
% showMatchedFeatures(traffic_gray, template_gray, traffic_matched_pts, template_matched_pts)


outputView = imref2d(size(traffic_gray));
R_tform = imwarp (template, tform, 'OutputView', outputView); 

figure(5);
imshow(R_tform);


imshowpair(traffic,R_tform,'blend');


