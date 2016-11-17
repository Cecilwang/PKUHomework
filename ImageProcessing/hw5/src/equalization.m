function dstImg = equalization(srcImg)
% dstImg = equalization(srcImg)
% Histogram equaliztion
% srcImg:  the source image
% dstImg:  the result image
%
% Created on: Mar 31, 2016
% Author: Wang Sixue (cecilwang@126.com)

if length(size(srcImg)) == 2
	[H, W] = size(srcImg);
    srcImg = reshape(srcImg, [H,W,1]);
end
[H,W,channel] = size(srcImg);

CDF = calculateCDF(srcImg);

dstImg = zeros(H,W,channel);
for i = 1:channel
    tmp = CDF(srcImg(:,:,i)+1, i);
    dstImg(:,:,i) = reshape(tmp, [H,W]);
end

if channel == 1
   dstImg = reshape(dstImg,[H,W]);
end

%imshow(dstImg, []);
end
