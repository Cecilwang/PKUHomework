function hist = calculateHist( Img )
% hist = calculateHist( Img )
%
% Created on: Mar 31, 2016
% Author: Wang Sixue (cecilwang@126.com)

channel = size(Img,3);
hist = zeros(256, channel);
for i = 0:255
    for j = 1:channel
        hist(i+1,j) = length(find(Img(:,:,j)==i));
    end
end

end

