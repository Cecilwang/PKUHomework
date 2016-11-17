function HSV = RGB2HSV( RGB )
% HSV = RGB2HSV( RGB )
%
% Created on: Apr 8, 2016
% Author: Wang Sixue (cecilwang@126.com)

[height, width, channel] = size(RGB);

RGB = mat2gray(RGB);
HSV = zeros(height,width,channel);

for i = 1:height
    for j = 1:width
        % V
        V = max(RGB(i,j,:));
        minVal = min(RGB(i,j,:));
        
        % H
        if V == minVal
            H = 0;
        elseif( V == RGB(i,j,1))
            H = 0 + 60 * (RGB(i,j,2) - RGB(i,j,3)) / (V - minVal);
        elseif ( V == RGB(i,j,2))
            H = 120 + 60 * (RGB(i,j,3) - RGB(i,j,1)) / (V - minVal);
        elseif( V == RGB(i,j,3))
            H = 240 + 60 * (RGB(i,j,1) - RGB(i,j,2)) / (V - minVal);
        end
        
        if H < 0
            H = H + 360;
        end
        %if H > 360
        %    H = H - 360;
        %    disp('H > 360!!!');
        %end
        
        
        % S
        if V == 0
            S = 0;
        else
            S = (V - minVal)/V;
        end
        
        HSV(i,j,1) = H;
        HSV(i,j,2) = S;
        HSV(i,j,3) = V;
    end
end
end

