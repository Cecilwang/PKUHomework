function ret = dfs(ret, x, y, low)
% ret = dfs(ret, x, y, low)
%
% Created on: Apr 25, 2016
% Author: Wang Sixue (cecilwang@126.com)

to=[-1 -1;-1 0;-1 1;0 -1;0 1;1 -1;1 0;1 1]; 
[n, m]=size(ret);
for i = 1 : 8
    newx = x + to(i,1);
    newy = y + to(i,2);
    if newx >= 1 && newx <= n && newy >= 1 && newx <= m  
        if ret(newx, newy) >= low && ret(newx, newy) ~= 255 
        	ret(newx, newy) = 255;
            ret = dfs(ret, newx, newy, low);
        end
    end        
end 

end