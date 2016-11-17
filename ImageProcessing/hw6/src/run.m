%% This script is used to show my homework6
% Created on: Apr 8, 2016
% Author: Wang Sixue (cecilwang@126.com)

set(gcf, 'position', [200 200 1000 600]);

% read image
RGB = imread('../img/src.jpg');
subplot(3,3,1); imshow(RGB, []); title('SRC');
%RGB = imresize(RGB, [200,341]);
%imwrite(RGB, '../img/src.jpg');

% RGB2HSV
HSV = RGB2HSV(RGB);
subplot(3,3,3); imshow( HSV2RGB(HSV), [] );title('HSV');

% HueShfit
dstHSV = HueShift(HSV, 120);
subplot(3,3,4); imshow( HSV2RGB(dstHSV), [] );title('H + 120');
dstHSV = HueShift(HSV, -120);
subplot(3,3,5); imshow( HSV2RGB(dstHSV), [] );title('H - 120');
dstHSV = HueShift(HSV, 90);
subplot(3,3,6); imshow( HSV2RGB(dstHSV), [] );title('H + 90');

% SaturationTune
dstHSV = SaturationTune(HSV, 0.3);
subplot(3,3,7); imshow( HSV2RGB(dstHSV), [] );title('S + 0.3');
dstHSV = SaturationTune(HSV, -0.5);
subplot(3,3,8); imshow( HSV2RGB(dstHSV), [] );title('S - 0,5');
dstHSV = SaturationTune(HSV, 0.7);
subplot(3,3,9); imshow( HSV2RGB(dstHSV), [] );title('S + 0.7');


