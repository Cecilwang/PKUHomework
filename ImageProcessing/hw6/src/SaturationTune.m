function dstHSV = SaturationTune(srcHSV, delta)
% dstHSV = SaturationTune(srcHSV)
%
% Created on: Apr 8, 2016
% Author: Wang Sixue (cecilwang@126.com)
    
    dstHSV = srcHSV;

    S = srcHSV(:,:,2);
    
    S = S * (1 + delta);
    S(find(S>1)) = 1.0;
    S(find(S<0)) = 0.0;

    dstHSV(:,:,2) = S;
end
