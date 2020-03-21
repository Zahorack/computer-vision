camList = webcamlist

cam = webcam(1)

preview(cam);

img = snapshot(cam);

image(img);

for idx = 1:50
    img = snapshot(cam);
    image(img);
end

clear cam