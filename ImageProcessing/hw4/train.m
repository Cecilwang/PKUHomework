%%This script will train classifier

%%
clear;
clc;
close all;

%% parameter
Iteration=40;
NPos=200;
NNeg=500;

%% Prepare the sample
[tmp1,Succ]=ReadImgSet('img/train/face',NPos,'trainp');
if Succ==0
    disp('Read Img Error');
    return;
end
[tmp2,Succ]=ReadImgSet('img/train/other',NNeg,'trainn');
if Succ==0
    disp('Read Img Error');
    return;
end
[h1,w1,NPos]=size(tmp1);
[h2,w2,NNeg]=size(tmp2);
if(h1~=h2 || w1~=w2)
    disp('Pictures size is different');
    return;
end
ImgSet=zeros(h1,w1,NPos+NNeg);
Lable=zeros(NPos+NNeg,1);
for i = 1:NPos
    ImgSet(:,:,i)=tmp1(:,:,i);
    Lable(i)=1;
end
for i = 1:NNeg
    ImgSet(:,:,i+NPos)=tmp2(:,:,i);
    Lable(i+NPos)=-1;
end   

disp('Train is starting');
disp('Creat Haar Feature');
feature = CreatHaarFeature(size(ImgSet,1),size(ImgSet,2),...
                    [size(ImgSet,1)/2,size(ImgSet,1)/2,...
                     size(ImgSet,2)/2,size(ImgSet,2)/2]);
                 
disp('Adaboost is starting');
classifier = adaBoost(ImgSet,Lable,feature,Iteration, NPos, NNeg);

save('data/classifier', 'classifier');


