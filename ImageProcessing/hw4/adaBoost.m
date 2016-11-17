function classifier = adaBoost(sample,sampleLable,feature,T,NPos,NNeg)
% classifier = adaBoost(sample,sampleLable,feature,T)

%% parameter
divideFactor=10;

%% output's struct
classifier.feature = cell(1,T);
classifier.p = zeros([1 T]);
classifier.weight = zeros([1 T]);
classifier.theta = zeros([1 T]);

%% calculate the feature result
nsample=length(sampleLable);
nfeature=length(feature);
result = zeros([nfeature nsample]);

dataName = ['data/result',mat2str(NPos),'-',mat2str(NNeg),'.mat'];
if ~exist(dataName, 'file')
    %parfor i = 1:nfeature
    for i = 1:nfeature
        %disp(['The ',mat2str(i), 'th feature']);
        for j = 1:nsample
            img = sample(:,:,j);
            onefeature = feature{i};
            coordinate = onefeature(:,1:4);
            tmp = img(coordinate(:));
            tmp = tmp(1:4:end) - tmp(2:4:end) - tmp(3:4:end) + tmp(4:4:end);
            tmp = tmp .* onefeature(:,5);
            result(i,j) = sum( tmp );
        end
    end
    save(dataName, 'result');
else
    load(dataName);
end

minresult = min(result,[],2);
maxresult = max(result,[],2);
deltaresult = (maxresult-minresult)/divideFactor;
disp('--Calculate feature result done!');

%% select the weak classifier
weights = zeros(nsample,1);
weights(:)=1.0/nsample;

for t = 1:T
    disp(['----The ',mat2str(t), 'th classifier']);
    
    %% calculate the error and choose the minimum error
    weights = weights / sum(weights);
           
    tmp = min(minresult) : min(deltaresult) : max(maxresult); 
    recorder = zeros(length(tmp),4);
    for p_i = -1 : 2 : 1
        %parfor i = 1:length(tmp)
        for i = 1:length(tmp)
            theta_i = tmp(i);
            ht = ones(size(result));
            ht(find(p_i*result >= p_i*theta_i)) = -1; 
            error = abs(ht - ones(length(feature),1)*sampleLable')/2; 
            error = error*weights;
            [minerror, index] = min(error);
            recorder(i,:) = [minerror index p_i theta_i]; 
        end
    end
    
    [minerror, index] = min(abs(recorder(:,1))) ;
    tmpval = minerror / (1.0 - minerror);
    if (tmpval == 0) tmpweight = 1.0; else tmpweight = 0.5 * log (1.0/tmpval); end
    
    f_ = recorder(index,2);
    p_ = recorder(index,3);
    th_ = recorder(index,4);
    
    classifier.feature{t} = feature{f_};
    classifier.weight(t) = tmpweight;
    classifier.p(t) = p_;
    classifier.theta(t) = th_;
    disp('-------Calculate error done!');
    fprintf('-------feature %d weight %.5f p %d theta %.5f',...
            f_, tmpweight, p_, th_ );
    
    %% update weights
    ht = ones(size(sampleLable));
    ht(find(p_ * result(f_,:) >= p_ * th_)) = -1; 
    
    Z = sum(weights(find((sampleLable - ht) == 0))) * exp(-tmpweight)...
        + sum(weights(find((sampleLable - ht) ~= 0))) * exp(tmpweight);
 
    for i = 1 : nsample
        if(sampleLable(i) ~= ht(i))
           weights(i) = weights(i)*exp(tmpweight)/Z; 
        else
           weights(i) = weights(i)*exp(-tmpweight)/Z; 
        end
    end
   
    %% remove the feature
    feature(f_)=[];
    result(f_,:)=[];
    minresult(f_)=[];
    maxresult(f_)=[];
    deltaresult(f_)=[];
    
    %% output information
    LablePredicted = ClassifierDetect(classifier, sample, t);
    error = sum(sampleLable~=LablePredicted')/double(nsample);
    fprintf(' error %.7f\n', error);

end

end
