% Homework2
% Description:
% 1. Get your matlab platform ready. Pay special attention to the image 
% processing toolbox.
% 2. Use matlab functions to convert the attached image from .jpg to 
% binary .ppm format. Save it as greens.ppm.
% 3. Write your own imread(¡®*.ppm¡¯) function code to read the newly 
% generated .ppm file.
%
% AUTHOR  Cecil Wang 2016/3/9

%----------------------------------------------------------------------
% The second part of homework

%read the image
image1 = imread('img/greens.jpg');     

%set figure's name 
figure('Name', 'greens.jpg');

%show the image
imshow(image1);   

%save the image
imwrite(image1, 'img/greensa.ppm', 'ppm', 'Encoding', 'ASCII');  
imwrite(image1, 'img/greensr.ppm', 'ppm', 'Encoding', 'rawbits');  
gray = rgb2gray(image1);
imwrite(gray, 'img/greensa.pgm', 'pgm', 'Encoding', 'ASCII');  
imwrite(gray, 'img/greensr.pgm', 'pgm', 'Encoding', 'rawbits');  
bimg = im2bw(gray);
imwrite(bimg, 'img/greensa.pbm', 'pbm', 'Encoding', 'ASCII');  
imwrite(bimg, 'img/greensr.pbm', 'pbm', 'Encoding', 'rawbits');  
%----------------------------------------------------------------------

%----------------------------------------------------------------------
% The third part of homework

%use my own function to read the image
image2 = myImageRead('img/greensa.ppm');

%set figure's name 
figure('Name', 'greensa.ppm');

%show the image
imshow(image2);          
disp('greensa.ppm')

image2 = myImageRead('img/greensr.ppm');
figure('Name', 'greensr.ppm');
imshow(image2); 
disp('greensr.ppm')

image2 = myImageRead('img/greensa.pgm');
figure('Name', 'greensa.pgm');
imshow(image2); 
disp('greensa.pgm')

image2 = myImageRead('img/greensr.pgm');
figure('Name', 'greensr.pgm');
imshow(image2); 
disp('greensr.pgm')

image2 = myImageRead('img/greensa.pbm');
figure('Name', 'greensa.pbm');
imshow(image2); 
disp('greensa.pbm')

image2 = myImageRead('img/greensr.pbm');
figure('Name', 'greensr.pbm');
imshow(image2); 
disp('greensr.pbm')
%----------------------------------------------------------------------

    
