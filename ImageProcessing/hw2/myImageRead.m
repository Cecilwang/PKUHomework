function [image] = myImageRead(imagePath)
% [image] = myImageRead(imagePath)
% Read the image from the imagePath
%
% Formats that can be processed:
%       pbm     Portable Bit Map
%       pgm     Portable Gray Map
%       ppm     Portable Pix Map
%
% AUTHOR  Cecil Wang 2016/3/9
%----------------------------------------------------------------------

% open image as a file
file = fopen(imagePath, 'r');

% read one or more images
while ~feof(file)
    
    %-----------------------------------------------------------------
    %read the description of the image
    findNum = 0;
    while findNum < 4
        line = fgetl(file);
        % filtering out the comments
        tmp = strfind(line, '#');
        if isempty(tmp) == 0
            line = line(1:tmp(1) - 1);
        end
        line = strtrim(line);
        
        % read format
        if findNum == 0
            format = line(1:2);
        	line = line(3:length(line));
            findNum = findNum + 1;
        end
        
        % read width, height, maxval
        tparam = str2num(line);
        for i=1:length(tparam)
            param(findNum + i - 1) = tparam(i);
        end
        findNum = findNum + length(tparam);

        if (strcmp(format, 'P1') || strcmp(format , 'P4')) && findNum == 3
            param(3) = 0;
            break;
        end
    end
    
    width = param(1);
    height = param(2);
    maxval = param(3);
    
    % sorry my read paramaters function can't process pbm save as rawbit
    % so I need another way to read it again
    % I'll fix this bug in future
    if(strcmp(format, 'P4'))
        fclose(file);
        file = fopen(imagePath, 'r');
        format = fscanf(file, '%s', 1);
        width = fscanf(file, '%d', 1);
        fill = ceil(width/8)*8 - width;
        height = fscanf(file, '%d', 1);
        % yes There is the bug! A whitespace! Only one!
        fread(file, 1, 'uint8');
    end
    %-----------------------------------------------------------------
    
    
    %-----------------------------------------------------------------
    % read data
    isbreak = 0;
    switch format
        % pbm save as ASCII
        case 'P1'
            for i = 1 : height
                for j = 1 : width
                    tmp = fscanf(file, '%d', 1);
                    if tmp == 0
                        image(i, j) = true;
                    else
                        image(i, j) = false;
                    end
                end
            end
            isbreak = 1;
            
        % pgm save as ASCII
        case 'P2'
        	image = zeros(height, width, 1, 'uint8');
            for i = 1 : height
                for j = 1 : width
                    image(i, j) = fscanf(file, '%d', 1);
                end
            end
            isbreak = 1;
            
        % ppm save as ASCII
        case 'P3'
            image = zeros(height, width, 3, 'uint8');
            for i = 1 : height
                for j = 1 : width
                    for k = 1 : 3
                        image(i, j, k) = fscanf(file, '%d', 1);
                    end
                end
            end
            isbreak = 1;
            
        % pbm save as rawbit
        case 'P4'
            tmp = fread(file, height * (width + fill), 'ubit1');
            for i = 1 : height
                for j = 1 : width
                    image(i, j) = ~logical(tmp((i - 1) * (width + fill) + j));
                end
            end
            
        % pgm save as rawbit
        case 'P5'
            image = zeros(height, width, 1, 'uint8');
            if maxval < 256
                tmp = fread(file, height * width, 'uint8');
            else
                tmp = fread(file, height * width, 'uint16');
            end
            for i = 1 : height
                for j = 1 : width
                    image(i, j) = tmp(((i -1) * width) + j);
                end
            end
            
        % ppm save as rawbit
        case 'P6'
            image = zeros(height, width, 3, 'uint8');
            if maxval < 256
                tmp = fread(file, 3 * height * width, 'uint8');
            else
                tmp = fread(file, 3 * height * width, 'uint16');
            end
            for i = 1 : height
                for j = 1 : width
                    for k = 1 : 3
                        image(i, j, k) = tmp((i - 1) * 3 * width + (j - 1) * 3 + k);
                    end
                end
            end
            
        % othe case
        otherwise
            disp('Can''t process this format');
    end
    %-----------------------------------------------------------------
    
    %imshow(image);
    % The ASCII file has only one image
    if isbreak == 1 
        break;
    end
    
    % To be convenient, the function will return only one image
    % if you want more image you can change the API
    break;
end


% close file
fclose(file);
