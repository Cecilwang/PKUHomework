%% Homework3
% Write your own imresize() function code to simulate the matab function imresize(). 
% You should implement at least the ¡®nearest¡¯ and the ¡®bilinear¡¯ methods. 
% Compare you result with the matlab function imresize(). 
%
%
% AUTHOR  Cecil Wang 2016/3/20


%% Init
clc;
clear;
scale = 0.3;

%% Read Image
img = imread('img/jordan.jpg');

%% Process

tic; [output,succ] = myresize(img,scale,'nearest','raw'); toc;
if succ == false
    return;
end
figure(1); imshow(output); pause(2); close(figure(1));
imwrite(output,'img/n-r.jpg');

tic; [output,succ] = myresize(img,scale,'bilinear','raw'); toc;
if succ == false
    return;
end
figure(1); imshow(output); pause(2); close(figure(1));
imwrite(output,'img/b-r.jpg');

tic; [output,succ] = myresize(img,scale,'bilinear','parfor'); toc;
if succ == false
    return;
end
figure(1); imshow(output); pause(2); close(figure(1));
imwrite(output,'img/b-p.jpg');

tic; [output,succ] = myresize(img,scale,'bilinear','gpu'); toc;
if succ == false
    return;
end
figure(1); imshow(output); pause(2); close(figure(1));
imwrite(output,'img/b-g.jpg' );