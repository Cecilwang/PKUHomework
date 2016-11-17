function dstHSV = HueShift( srcHSV, delta )
% dstHSV = HueShift( srcHSV )
%
% Created on: Apr 8, 2016
% Author: Wang Sixue (cecilwang@126.com)

    dstHSV = srcHSV;

    H = srcHSV(:,:,1);
    
    H = H + delta;
    H(find(H>=360)) = H(find(H>=360)) - 360;
    H(find(H<0)) = H(find(H<0)) + 360;

    dstHSV(:,:,1) = H;

end

