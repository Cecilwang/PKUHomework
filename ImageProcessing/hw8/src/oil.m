function ret = oil( img, I, filtersize )
% ret = oil( img, I, filtersize )
%
% Created on: May 17, 2016
% Author: Wang Sixue (cecilwang@126.com)

[h,w,~] = size(img);
ret = img;

for i = 1:h
    for j = 1:w
        sum_ret = zeros(I+2,4);
        for x = -filtersize:filtersize
            for y = -filtersize:filtersize
                if(i+x<1 || j+y<1 || i+x>h || j+y>w) 
                    continue; 
                end
                rgb = img(i+x, j+y, :);
                rgb = reshape(rgb,[1,3]);
                cI = round(sum(rgb) / (3 * 255) * I) + 1;
                sum_ret(cI,:) = uint32(sum_ret(cI,:)) + uint32([1,rgb]);
            end
        end
        [maxI, maxP] = max(sum_ret(:,1));
        rgb = sum_ret(maxP,2:4) / maxI;
        ret(i,j,:) = rgb;
    end
end

end