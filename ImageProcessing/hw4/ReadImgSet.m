function [ImgSet, Succ] = ReadImgSet(Path, Total, type)
% ImgSet = ReadImg(Path, Num)
% Read all images from the Path

Succ=0;
H=30;
W=30;

if ~exist(Path, 'dir')
   disp('No such folder') ;
   ImgSet=0;
   Succ=0;
   return;
end

%dataName=['data/',type,mat2str(Total),'.mat'];
%if exist(dataName, 'file')
%    load(dataName);
%    Succ=1;
%    return;
%end

num=1;

imgList=dir(Path);
imgNum=length(imgList);
n = min(Total, imgNum-2);

ImgSet=zeros(H,W,n);

for i = 1:n
    imgname = strcat(Path,'/',imgList(i+2).name);
    img=imread(imgname);
    %[h1,w1,d1]=size(img);
    %[h2,w2,d2]=size(ImgSet);
    %if(h1~=h2 || w1~=w2)
    %    delete(imgname);
    %    disp('w');
    %    continue;
    %end
    img = imresize(img, [H,W]);    
    if( length(size(img)) == 3 )
        img=rgb2gray(img);
    end
    img=double(img)/255.0;
    
    %ImgSet(:,:,num)=img;
    ImgSet(:,:,num)=cumsum( cumsum( img, 1 ), 2 );
    num=num+1;
end

%disp([num, imgNum]);

%save(dataName, 'ImgSet');
Succ = 1;

end



