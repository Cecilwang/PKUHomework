%% This script is used to show my homework7
% Created on: Apr 25, 2016
% Author: Wang Sixue (cecilwang@126.com)


%%
clear all;
close all;
clc;


%set(gcf, 'position', [200 200 1000 600]);

img = imread('../img/coins.png'); 
if length(size(img)) == 3
    img = rgb2gray(img);
end
subplot(3,3,1); imshow(img, []); title('coins.png-src');
cannyimg = canny(img);
subplot(3,3,2); imshow(cannyimg, []); title('coins.png-canny');
circleimg = findcircle(cannyimg, 0.85);
subplot(3,3,3); imshow(circleimg, []); title('coins.png-dst');

img = imread('../img/pillsetc.png'); 
if length(size(img)) == 3
    img = rgb2gray(img);
end
subplot(3,3,4); imshow(img, []); title('pillsetc.png-src');
cannyimg = canny(img);
subplot(3,3,5); imshow(cannyimg, []); title('pillsetc.png-canny');
circleimg = findcircle(cannyimg, 0.45);
subplot(3,3,6); imshow(circleimg, []); title('pillsetc.png-dst');

img = imread('../img/tape.png'); 
if length(size(img)) == 3
    img = rgb2gray(img);
end
subplot(3,3,7); imshow(img, []); title('tape.png-src');
cannyimg = canny(img);
subplot(3,3,8); imshow(cannyimg, []); title('tape.png-canny');
circleimg = findcircle(cannyimg, 0.8);
subplot(3,3,9); imshow(circleimg, []); title('tape.png-dst');
