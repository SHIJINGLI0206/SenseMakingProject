function [label] = crc_1action_classifier(F_train, F_train_size,file_name,group_no)
%CRC_1ACTION_CLASSIFIER Summary of this function goes here
%   Detailed explanation goes here

 
NumAct = 8;
 
lambda = 0.001;      % Tikhonov regularization parameter (parameter tuning for the optimal value)
frame_remove = 5;    % remove the first and last five frames (mostly the subject is in stand-still position in these frames)

ActionSets = ["AS1","AS2","AS3"];
ActionSet = ActionSets(group_no);  % group_actions = 1,2,3

switch ActionSet
    case 'AS1'
        subset = 1;
        fix_size_front = round([100;50]/2); fix_size_side = round([100;82]/2); fix_size_top = round([82;47]/2);
    case 'AS2'
        subset = 2;
        fix_size_front = round([102;51]/2); fix_size_side = round([103;67]/2); fix_size_top = round([67;51]/2);
        %fix_size_front = [102;51]; fix_size_side = [103;67]; fix_size_top = [67;51];
    case 'AS3'
        subset = 3;
        fix_size_front = round([104;53]/2); fix_size_side = round([104;84]/2); fix_size_top = round([84;53]/2);
        %fix_size_front = [104;53]; fix_size_side = [104;84]; fix_size_top = [84;53];
end
D = prod(fix_size_front)+prod(fix_size_side)+prod(fix_size_top);
TotalFeature = zeros(D,1);

%% Generate DMM for all depth sequences in test action set
load(file_name);
depth = d_depth(:,:,frame_remove+1:end-frame_remove);
[front, side, top] = depth_projection(depth);
front = resize_feature(front,fix_size_front);
side  = resize_feature(side,fix_size_side);
top   = resize_feature(top,fix_size_top);
TotalFeature(:,1) = [front;side;top];
fprintf('Finish feature extraction at: %s\n', datetime('now'));

%% Generate   testing data
F_test = TotalFeature;


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
fprintf('Finish CRC at: %s\n', datetime('now'));
end

