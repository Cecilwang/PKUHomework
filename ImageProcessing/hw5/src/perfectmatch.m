function resultImg = perfectmatch(srcImg, dstImg)
% dstImg = perfectmatch(srcImg, dstImg)
% Histogram  perfect matching
% srcImg:       the source image
% dstImg:       the destination image
% resultImg:    the result image
%
% Created on: Mar 31, 2016
% Author: Wang Sixue (cecilwang@126.com)


if length(size(srcImg)) == 2
	[srcH, srcW] = size(srcImg);
    srcImg = reshape(srcImg, [srcH,srcW,1]);
end
[srcH,srcW,srcChannel] = size(srcImg);
[dstH,dstW,dstChannel] = size(dstImg);
dstImg = imresize(dstImg,[srcH, srcW]);

srcHist = calculateHist(srcImg);
dstHist = calculateHist(dstImg);

resultImg = zeros(srcH,srcW,srcChannel);
for j = 1:srcChannel
    excessPiexl = [];
    tmpImg=zeros(srcH*srcW, 1);
    
    for i = 1:256
        if( srcHist(i,j) > dstHist(i,j))
            val = srcHist(i,j) - dstHist(i,j);
            id = find(srcImg(:,:,j)==i-1);
            excessPiexl = [ excessPiexl id(1:val)' ];
            tmpImg(id(val+1:end)) = i-1;
        end
    end
    
    for i = 1:256
        if( srcHist(i,j) < dstHist(i,j))
            val = dstHist(i,j) - srcHist(i,j);
            tmpImg(excessPiexl(1:val)) = i-1;
            excessPiexl = excessPiexl(val+1:end);
            tmpImg(find(srcImg(:,:,j)==i-1)) = i-1;
        end
    end
 
    for i = 1:256
        if( srcHist(i,j) == dstHist(i,j))
            tmpImg(find(srcImg(:,:,j)==i-1)) = i-1;
        end
    end
    
   
    resultImg(:,:,j) = reshape(tmpImg,[srcH,srcW]);
end

if srcChannel == 1
   resultImg = reshape(resultImg,[srcH,srcW]);
end

resultImg = resultImg/255.0;

%imshow(resultImg,[]);
end