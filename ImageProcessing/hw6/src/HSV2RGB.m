function RGB = HSV2RGB( HSV )
% RGB = HSV2RGB( HSV )
%
% Created on: Apr 8, 2016
% Author: Wang Sixue (cecilwang@126.com)

[height, width, channel] = size(HSV);

RGB = zeros(height,width,channel);
val = zeros(1,4);

index=[ 
    4 3 1
    2 4 1
    1 4 3
    1 2 4
    3 1 4
    4 1 2
    ];

for i = 1:height
    for j = 1:width
        h = floor(HSV(i,j,1) / 60);
        f = HSV(i,j,1) / 60 - h;
        val(1) = HSV(i,j,3) * ( 1 - HSV(i,j,2) );
        val(2) = HSV(i,j,3) * ( 1 - f * HSV(i,j,2) );
        val(3) = HSV(i,j,3) * ( 1 - (1 - f) * HSV(i,j,2) );
        val(4) = HSV(i,j,3);

        RGB(i,j,:) = val(index(h+1,:));
    end
end

end

