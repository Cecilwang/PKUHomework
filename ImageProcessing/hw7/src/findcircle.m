function ret = findcircle( img, percentage )
% ret = findcircle( img )
%
% Created on: Apr 25, 2016
% Author: Wang Sixue (cecilwang@126.com)

%% init
%percentage = 0.45;
eps = 3;
[n m] = size(img);
[candidatex, candidatey] = find(img ~= 0);
npix = length(candidatex);
angle_range = 2 * pi;
%r_range = sqrt(n * n + m * m);
r_range = min(n,m) / 3;

%% hough
h = zeros(n, m, r_range);   
for i =  1 : 1 : npix
	for r = 10 : 1 : r_range
        for angle = pi / 180 : pi / 181 : angle_range
            x = round(candidatex(i) - r * cos(angle));  
            y = round(candidatey(i) - r * sin(angle));  
            if(x > 0 && x <= n && y > 0 && y <= m)  
                h(x, y, r) = h(x, y, r) + 1;
            end 
        end
    end
end
   
%% filter candidate
maxval = max(max(max(h)));
index = find(h >= maxval * percentage);
ncondidate = length(index);

ret = zeros(n, m);  
for j = 1 : ncondidate
    [x2, y2, r] = ind2sub(size(h), index(j));
    minr = r - eps;
    maxr = r + eps;
    for i = 1 : npix    
        x1 = candidatex(i);
        y1 = candidatey(i);
        r = sqrt( (x1 - x2)^2 + (y1 - y2)^2 );
        
        if minr < r && r < maxr
            ret(x1, y1) = 1;
        end
    end  
end  
%imshow(ret, []);

end
