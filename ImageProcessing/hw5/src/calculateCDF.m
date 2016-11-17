function CDF = calculateCDF( Img )
% CDF = calculateCDF( Img )
%
% Created on: Mar 31, 2016
% Author: Wang Sixue (cecilwang@126.com)

[H,W,channel] = size(Img);
hist = calculateHist(Img);
CDF = cumsum(hist, 1);
CDF = CDF / double(H) / double(W);
CDF(find(CDF>255)) = 255;
CDF(find(CDF<0)) = 0;
end

