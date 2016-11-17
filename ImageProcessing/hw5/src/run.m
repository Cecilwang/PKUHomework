 %% This script is used to show my homework5
% Created on: Mar 31, 2016
% Author: Wang Sixue (cecilwang@126.com)

% Histogram equaliztion
srcImg = imread('../img/vimium.jpg');
srcImg = equalization(srcImg);
figure(1); 
subplot(1,2,1); imshow(srcImg,[]); title('src');
subplot(1,2,2); imshow(srcImg,[]); title('dst');
%pause(2); close(figure(1));
imwrite(srcImg,'../img/r.jpg');

% Histogram matching
srcImg = imread('../img/r.jpg');
dstImg = imread('../img/TheScream.jpg');
resultImg = matching(srcImg, dstImg);
figure(2); 
subplot(1,3,1); imshow(srcImg,[]); title('src');
subplot(1,3,2); imshow(dstImg,[]); title('dst');
subplot(1,3,3); imshow(resultImg,[]); title('result');
%pause(2); close(figure(1));
imwrite(resultImg,'../img/r1.jpg');

% Histogram perfect matching
srcImg = imread('../img/r1.jpg');
dstImg = imread('../img/TheScream.jpg');
resultImg = perfectmatch(srcImg, dstImg);
figure(3); 
subplot(1,3,1); imshow(srcImg,[]); title('src');
subplot(1,3,2); imshow(dstImg,[]); title('dst');
subplot(1,3,3); imshow(resultImg,[]); title('result');
%pause(2); close(figure(1));
imwrite(resultImg,'../img/r2.jpg');