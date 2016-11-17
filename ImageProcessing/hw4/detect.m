%%This script will detect the face
%The is a sample methmod to detect face
%just for test the classifier

%%
clear;
clc;
close all;

%% parameter
NPos=50;
NNeg=50;

%%
load('data/classifier.mat');


[Psample,Succ]=ReadImgSet('img/test/face',NPos,'detectp');
NPos = size(Psample,3);
if Succ==0
    disp('Read Img Error');
    return;
end
[Nsample,Succ]=ReadImgSet('img/test/other',NNeg,'detectn');
NNeg = size(Nsample,3);
if Succ==0
    disp('Read Img Error');
    return;
end

PLablePredicted = ClassifierDetect(classifier, Psample, 0);
Lable = ones(1,NPos);
Perror = sum(Lable~=PLablePredicted)/double(NPos);

NLablePredicted = ClassifierDetect(classifier, Nsample, 0);
Lable = ones(1,NNeg);
Lable = -Lable;
Nerror = sum(Lable~=NLablePredicted)/double(NNeg);

fprintf('The Psample error %.3f\n', Perror);
fprintf('The Nsample error %.3f\n', Nerror);

error = (NPos * Perror + NNeg * Nerror) / (NPos + NNeg);
fprintf('The Total error %.3f\n', error);

