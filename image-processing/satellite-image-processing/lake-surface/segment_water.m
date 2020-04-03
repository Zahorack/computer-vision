function water = segment_water(img)
    gray = rgb2gray(img);
    level = graythresh(gray);
    bin_mask = imbinarize(gray,level);

    erosion = strel('disk', 10);
    bin_mask = imclose(bin_mask, erosion);
    bin_mask = imopen(bin_mask, erosion);
    bin_mask = ~bin_mask;
    
    water(:,:,1) = img(:,:,1).*uint8(bin_mask);
    water(:,:,2) = img(:,:,2).*uint8(bin_mask);
    water(:,:,3) = img(:,:,3).*uint8(bin_mask);
end