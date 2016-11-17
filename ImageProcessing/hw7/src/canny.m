function ret = canny( img )
% ret = canny( img )
%
% Created on: Apr 25, 2016
% Author: Wang Sixue (cecilwang@126.com)

%% init
up = 220;
low = 200;
[n,m] = size(img);
img = double(img);

%% 高斯平滑
filter = fspecial('gaussian');
img = imfilter(img, filter);

%% sobel边缘检测
filter = fspecial('sobel');
img_w = imfilter(img, filter);
filter = filter';
img_h = imfilter(img, filter);
img = sqrt(img_w.^2 + img_h.^2);
%imshow(ret,[]);

%% NMS
ret = zeros(n,m);
for i = 2:n-1
    for j = 2:m-1
        if img(i, j)~=0
            gx = img_w(i,j);
            gy = img_h(i,j);
            %角度
            if gy ~= 0
                theta=atan(gx / gy);      
            elseif gy == 0
                theta=pi/2;
            end
            if theta < 0
                theta = theta + pi;
            end
                
            %插值
            if (theta >= pi / 2) && (theta < pi * 3/4)
                h1 = tan(theta - pi / 2);
                h2 = 1 - h1;
                t1 = h1 * img(i-1,j-1) + h2 * img(i-1,j);
                t2 = h1 * img(i+1,j+1) + h2 * img(i+1,j);
            end
            
            if (theta >= pi * 3/4) && (theta <= pi)
                h1 = tan(pi - theta);
                h2 = 1 - h1;
                t1 = h1 * img(i-1,j-1) + h2 * img(i,j-1);
                t2 = h1 * img(i+1,j+1) + h2 * img(i,j+1);
            end
            
            if (theta >= pi / 4) && (theta < pi / 2)
                h1 = tan(pi / 2 - theta);
                h2 = 1 - h1;
                t1 = h1 * img(i-1,j+1) + h2 * img(i-1,j);
                t2 = h1 * img(i+1,j-1) + h2 * img(i+1,j);
            end
           
            if (theta >= 0) && (theta < pi/4)
                h1 = tan(theta);
                h2 = 1-h1;
                t1 = h1 * img(i-1,j+1) + h2 * img(i,j+1);
                t2 = h1 * img(i+1,j-1) + h2 * img(i,j-1);
            end
            
            %judge
            if (img(i,j) > t1) && (img(i,j) > t2)
                ret(i,j)= img(i, j);
                if ret(i, j) == 255
                    ret(i, j) = 254;
                end
            end
        end
    end
end

%% 连通
for i = 1 : n
    for j = 1 : m
      if ret(i, j) > up && ret(i, j) ~= 255 
            ret(i, j)=255;
            ret = dfs(ret, i , j, low);
      end
      
    end
end
ret(find(ret ~= 255)) = 0;

%imshow(ret,[]);

end



    %插值
        %{
        x1 = ceil(cos(theta + pi / 8) * sqrt(2) - 0.5);
        y1 = ceil(-sin(theta - pi / 8) * sqrt(2) - 0.5);
        x2 = ceil(cos(theta - pi / 8) * sqrt(2) - 0.5);
        y2 = ceil(-sin(theta - pi / 8) * sqrt(2) - 0.5);
        
        p1=gy * img(i + y1, j + x1) + ...
           (gx - gy) * img(i + y2 , j + x2);   
        
        theta = thera + pi;
        x1 = ceil(cos(theta + pi / 8) * sqrt(2) - 0.5);
        y1 = ceil(-sin(theta - pi / 8) * sqrt(2) - 0.5);
        x2 = ceil(cos(theta - pi / 8) * sqrt(2) - 0.5);
        y2 = ceil(-sin(theta - pi / 8) * sqrt(2) - 0.5);
        
        p2=gy * img(i + y1, j + x1) + ...
           (gx - gy) * img(i + y2, j + x2);   
       
        if (gx * img(i, j) > p1) * (gx * img(i,j) >= p2) + ...
           (gx * img(i, j) < p1) * (gx * img(i,j) <= p2);
           ret(i,j)=img(i,j); 
        end        
        %}
