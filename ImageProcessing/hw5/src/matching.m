function resultImg = matching(srcImg, dstImg)
% dstImg = matching(srcImg, dstImg)
% Histogram matching
% srcImg:       the source image
% dstImg:       the destination image
% resultImg:    the result image
%
% Created on: Mar 31, 2016
% Author: Wang Sixue (cecilwang@126.com)

if length(size(srcImg)) == 2
	[H, W] = size(srcImg);
    srcImg = reshape(srcImg, [H,W,1]);
end
[H,W,channel] = size(srcImg);

srcCDF = calculateCDF(srcImg);
dstCDF = calculateCDF(dstImg);

LUT = zeros(256,channel);
for i = 1:256
    for j = 1:channel
        tmp = find(dstCDF(:,j)>=srcCDF(i,j));
        if length(tmp)  == 0
            LUT(i,j) = 1.0;
        else
            LUT(i,j) = (tmp(1)-1)/255.0;
        end 
    end
end

resultImg = zeros(H,W,channel);
for i = 1:channel
    tmp = LUT(srcImg(:,:,i)+1, i);
    resultImg(:,:,i) = reshape(tmp,[H,W]);
end

if channel == 1
   resultImg = reshape(resultImg,[H,W]);
end

%imshow(resultImg,[]);

end