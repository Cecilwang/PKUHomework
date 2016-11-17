%% This script is used to show my homework8
% Created on: May 17, 2016
% Author: Wang Sixue (cecilwang@126.com)

%%
clear all;
close all;
clc;
%%
I = 60;
filtersize = 3;

%%
img = imread('../img/h1.jpg'); 
%img = imresize(img, [320 240]);
subplot(1,3,1); imshow(img, []); title('src');

oilimg = oil(img, I, filtersize);
subplot(1,3,2); imshow(oilimg, []); title('oil');

grayimg = rgb2gray(img);
tmpimg = edge(grayimg, 'canny', [0.2,0.25], 1.5);
tmpimg = uint32(tmpimg);
tmpimg(find(tmpimg == 0)) = 255;
tmpimg(find(tmpimg == 1)) = 0;
[h,w] = size(tmpimg);
edgeimg = zeros(h,w,3);
edgeimg(:,:,1) = tmpimg;
edgeimg(:,:,2) = tmpimg;
edgeimg(:,:,3) = tmpimg;
cartoonimg = min(uint8(edgeimg), uint8(oilimg));
subplot(1,3,3); imshow(cartoonimg, []); title('cartoon');
imwrite(cartoonimg,'../ret/ret.jpg');


