function [output, succ] = myresize(input, scale, method, parmethod)
% [output, succ] = myresize(input, scale, method, parmethod)
% resize img
%
% input is the original img
%
% scale is a positive double 
%
% method that can be processed
%       nearest
%       bilinear
%
% parmethod that can be processed
%       raw
%       parfor
%       gpu
%       CUDA(this will be supported in future)
%
% AUTHOR  Cecil Wang 2016/3/20

if scale <= 0.0
    disp('Scale must be a positive double');
    output = zeros(1);
    succ = false;
    return;
end;
    
if scale == 1.0
   output = input;
   succ = true;
   return;
end

switch method
    case 'nearest' 
        [output,succ] = nearest(input, scale, parmethod);
    case 'bilinear'
        [output,succ] = bilinear(input, scale, parmethod);
    otherwise
        disp('Method is error');
        succ = false;
        output = zeros(1);
        return;
end

end


function [output, succ] = nearest(input, scale, parmethod)

fscale = 1/scale;

[height, width, channels] = size(input);
height = height * scale;
width = width * scale;

output = zeros(height, width, channels, 'uint8');

switch parmethod
    case 'raw'
       for i = 1 : height
            x = max(fix(i * fscale), 1);
            for j = 1 : width
                y = max(fix(j * fscale), 1);
                output(i, j, :) = input(x, y, :);
            end
       end 
       succ = true;
    case 'parfor'
       parfor i = 1 : height
            x = max(fix(i * fscale), 1);
            for j = 1 : width
                y = max(fix(j * fscale), 1);
                output(i, j, :) = input(x, y, :);
            end
       end 
       succ = true;
    case 'gpu'
        disp('Sorry, I haven''t supported it');
        succ = false;
        output = zeros(1);
    case 'CUDA'
        disp('Sorry, I haven''t supported it');
        succ = false;
        output = zeros(1);
    otherwise
        disp('Parmethod is error');
        succ = false;
        output = zeros(1);
        return;
end

end

function [output, succ] = bilinear(input, scale, parmethod)

fscale = 1.0/scale;

[srcheight, srcwidth, channels] = size(input);
height = srcheight * scale;
width = srcwidth * scale;

output = zeros(height, width, channels, 'uint8');

switch parmethod
    case 'raw'
       for i = 1 : height
            srcX  = i * fscale;
            minX = max( floor(srcX), 1 );
            maxX = min( ceil(srcX), srcheight );
            b = abs( srcX - minX );
            for j = 1 : width
                srcY  = j * fscale;
                minY = max( floor(srcY), 1 );
                maxY = min( ceil(srcY), srcwidth );
                a = abs( srcY - minY );
                output(i,j,:) = (1-a) * (1-b) * input(minX, minY, :) + ...
                                (1-a) * b * input(maxX, minY, :) + ...
                                a * (1-b) * input(minX, maxY, :) + ...
                                a * b * input(maxX, maxY, :);
            end
       end 
       succ = true;
    case 'parfor'
       parfor i = 1 : height
            srcX  = i * fscale;
            minX = max( floor(srcX), 1 );
            maxX = min( ceil(srcX), srcheight );
            b = abs( srcX - minX );
            for j = 1 : width
                srcY  = j * fscale;
                minY = max( floor(srcY), 1 );
                maxY = min( ceil(srcY), srcwidth );
                a = abs( srcY - minY );
                output(i,j,:) = (1-a) * (1-b) * input(minX, minY, :) + ...
                                (1-a) * b * input(maxX, minY, :) + ...
                                a * (1-b) * input(minX, maxY, :) + ...
                                a * b * input(maxX, maxY, :);
            end
       end 
       succ = true;
    case 'gpu'
        u = zeros(height, width, channels, 'uint8');
        d = zeros(height, width, channels, 'uint8');
        l = zeros(height, width, channels, 'uint8');
        r = zeros(height, width, channels, 'uint8');
        a = zeros(height, width, channels);
        b = zeros(height, width, channels);
        
        for i = 1 : height
            srcX  = i * fscale;
            minX = max( floor(srcX), 1 );
            maxX = min( ceil(srcX), srcheight );
            b(i,:, :) = abs( srcX - minX );
            for j = 1 : width
                srcY  = j * fscale;
                minY = max( floor(srcY), 1 );
                maxY = min( ceil(srcY), srcwidth );
                a(i,j, :) = abs( srcY - minY );
                
                u(i,j,:) = input(minX, minY, :);
                d(i,j,:) = input(maxX, minY, :);
                l(i,j,:) = input(minX, maxY, :);
                r(i,j,:) = input(maxX, maxY, :);
            end
        end
       
        
        Agpu = gpuArray(a);
        Bgpu = gpuArray(b);
        Ugpu = gpuArray(u);
        Dgpu = gpuArray(d);
        Lgpu = gpuArray(l);
        Rgpu = gpuArray(r);
        
        f = @(a,b,u,d,l,r)(1-a) * (1-b) * u + ...
                          (1-a) * b * d + ...
                          a * (1-b) * l + ...
                          a * b * r;
        outputgpu = arrayfun(f,Agpu, Bgpu, Ugpu, Dgpu, Lgpu, Rgpu);

        output = gather(outputgpu);
        succ = true;
    case 'CUDA'
        disp('Sorry, I haven''t supported it');
        succ = false;
        output = zeros(1);
    otherwise
        disp('Parmethod is error');
        succ = false;
        output = zeros(1);
        return;
end

end


