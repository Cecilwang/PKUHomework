function [LablePredicted] = ClassifierDetect(Classifier, ImgSet, T)
% [LablePredicted] = ClassifierDetect(ImgSet)

nfeature = length(Classifier.feature);
if(T~=0) nfeature = min(nfeature, T); end
nImg = size(ImgSet,3);
result = zeros(nfeature, nImg);

for i = 1:nfeature
    for j = 1:nImg
        img = ImgSet(:,:,j);
        feature = Classifier.feature{i};
        coordinate = feature(:,1:4);
        tmp = img(coordinate(:));
        tmp = tmp(1:4:end) - tmp(2:4:end) - tmp(3:4:end) + tmp(4:4:end);
        tmp = tmp .* feature(:,5);
        tmp = sum( tmp );
        if(Classifier.p(i)*tmp < Classifier.p(i)*Classifier.theta(i))
            result(i,j) = Classifier.weight(i);
        else
            result(i,j) = -Classifier.weight(i);
        end
    end
end    

result  = sum( result, 1 );
LablePredicted = sign(result); 
        
end

