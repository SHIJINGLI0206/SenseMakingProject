function [label] = one_action_classifier(NumAct,OneActionSample)
%BUILD_MODEL Summary of this function goes here
%   Detailed explanation goes here

T = 3;               % number of samples of each subject for training

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% You may consider to save the training and testing samples for speed.
% save(strcat(ActionSet,'.Features.mat'), 'TotalFeature');
%
% Load the feature file if there isn't going to be any changes on the
% feature set.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Generate training and testing data

F_train_size = zeros(1,NumAct);
F_test_size = zeros(1,NumAct);
error = zeros(1,NumAct);
F_train = [];
F_test = [];
Index_Action_Test = 3;

count = 0;
for i = 1:NumAct      
    F = TotalFeature(:,count+1:count+OneActionSample(i));
    ID = sample_ind{i};
    ID(ID(:,1)==0,:) = [];
    num_subject = size(ID,1);  % number of subjects in one action
    F1 = zeros(D,T*num_subject);
    F2 = [];   

    start = 0;
    for j = 1:num_subject
        num_sample = sum(ID(j,:));
        tmp = F(:,start+1:start+num_sample);
        F1(:,(j-1)*T+1:j*T) = tmp(:,1:T); 
        if T < num_sample && isempty(F2)
            F2 = [F2 tmp(:,T+1:end)];
        end   
        start = start + num_sample;
    end

    F_train_size(i) = size(F1,2);   
    F_test_size(i) = size(F2,2);
    F_train = [F_train F1];
    if i == Index_Action_Test
        F_test = [F_test F2];
    end
    count = count + OneActionSample(i);
end
clear F1 F2
fprintf('Finish generate training data and test data at: %s\n', datetime('now'));
%%%%% PCA on training samples and test samples

Dim = size(F_train,2) - 35; % AS1:20; AS2:35; AS3:35 (Try a set of dimensions and tune the reduced dimensionality for optimal result)
disc_set = Eigenface_f(single(F_train),Dim);
F_train = disc_set'*F_train;
F_test  = disc_set'*F_test;
F_train = F_train./(repmat(sqrt(sum(F_train.*F_train)), [Dim,1]));
F_test  = F_test./(repmat(sqrt(sum(F_test.*F_test)), [Dim,1]));
fprintf('Finish PCA on train and test data at: %s\n', datetime('now'));

%% Testing

%////////////////////////////////////////////////////////////////////%    
%         Tikhonov regularized Collaborative Classifier              %
%////////////////////////////////////////////////////////////////////%

label = L2_CRC(F_train, F_test, F_train_size, NumAct, lambda);
end

