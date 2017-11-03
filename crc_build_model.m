function [accuracy,F_train_model, F_train_size_model] = crc_build_model(group_no)
%CRC_BUILD_MODEL Summary of this function goes here
%   Detailed explanation goes here
%EXTRACT_FEATURES Summary of this function goes here
%   Detailed explanation goes here

file_dir = 'Data2\';
ActionNum = ['a01','a02','a03','a04','a05','a06','a07','a09';
             'a10','a11','a12','a13','a14','a15','a16','a17';
             'a18','a19','a20','a21','a22','a24','a25','a26'];
%,'a10','a11','a12','a13','a14','a15','a16','a17','a18','a19','a20','a21','a22','a24','a25','a26'];
%               ['a02', 'a03', 'a05', 'a06', 'a10', 'a13', 'a18', 'a20']; % first row corresponds to action subset 'AS1'
%             'a01', 'a04', 'a07', 'a08', 'a09', 'a11', 'a14', 'a12'; % second row corresponds to action subset 'AS2'
%             'a06', 'a14', 'a15', 'a16', 'a17', 'a18', 'a19', 'a20']; % third row corresponds to action subset 'AS3'
            
NumAct = 8; % default 8;          % number of actions in each subset
row = 240;
col = 320;
max_subject = 8;     %default 10    % maximum number of subjects for one action
max_experiment = 3;  % default 3;  % maximum number of experiments performed by one subject
lambda = 0.001;      % Tikhonov regularization parameter (parameter tuning for the optimal value)
frame_remove = 5;    % remove the first and last five frames (mostly the subject is in stand-still position in these frames)

T = 2;               % number of samples of each subject for training

ActionSets = ["AS1","AS2","AS3"];
ActionSet = ActionSets(group_no);  % group_actions = 1,2,3


fprintf('Action set: %s; %d training sample(s) of each subject\n', ActionSet, T);
fprintf('Start Work at: %s\n', datetime('now'));

switch ActionSet
    case 'AS1'
        subset = 1;
        fix_size_front = round([100;50]/2); fix_size_side = round([100;82]/2); fix_size_top = round([82;47]/2);
        %fix_size_front = [100;50]; fix_size_side = [100;82]; fix_size_top = [82;47];

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

TargetSet = ActionNum(subset,:);
TotalNum = max_subject*max_experiment*NumAct; % assume 10 subjects, 3 experiments per subject for each action
TotalFeature = zeros(D,TotalNum);


%% Generate DMM for all depth sequences in one action set

sample_ind = cell(1,NumAct);
OneActionSample = zeros(1,NumAct);
for i = 1:NumAct
    action = TargetSet((i-1)*3+1:i*3);
    action_dir = strcat(file_dir,action,'\');
    fpath = fullfile(action_dir, '*.mat');
    depth_dir = dir(fpath);
    ind = zeros(max_subject,max_experiment);
    for j = 1:length(depth_dir)
        depth_name = depth_dir(j).name;
        len_file_name = length(depth_name);
        if len_file_name == 18
            sub_num = str2double(depth_name(5)); % default (6:7)
            exp_num = str2double(depth_name(8)); % default (10:11)
        else
            sub_num = str2double(depth_name(6)); % default (6:7)
            exp_num = str2double(depth_name(9)); % default (10:11)
        end
        ind(sub_num,exp_num) = 1;
        load(strcat(action_dir,depth_name));
        %depth = depth(:,:,frame_remove+1:end-frame_remove); % default 
        depth = d_depth(:,:,frame_remove+1:end-frame_remove);
        [front, side, top] = depth_projection(depth);
        front = resize_feature(front,fix_size_front);
        side  = resize_feature(side,fix_size_side);
        top   = resize_feature(top,fix_size_top);
        TotalFeature(:,sum(OneActionSample)+j) = [front;side;top];
    end
    OneActionSample(i) = length(depth_dir);
    sample_ind{i} = ind;
end
TotalFeature = TotalFeature(:,1:sum(OneActionSample));
fprintf('Finish feature extraction at: %s\n', datetime('now'));


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
        if T < num_sample
            F2 = [F2 tmp(:,T+1:end)];
        end   
        start = start + num_sample;
    end

    F_train_size(i) = size(F1,2);   
    F_test_size(i) = size(F2,2);
    F_train = [F_train F1];
    F_test = [F_test F2];
    count = count + OneActionSample(i);
end
clear F1 F2
fprintf('Finish generating training data and test data at: %s\n', datetime('now'));
%%%%% PCA on training samples and test samples
F_train_model = F_train;
F_train_size_model = F_train_size;
Dim = size(F_train,2) - 35; % AS1:20; AS2:35; AS3:35 (Try a set of dimensions and tune the reduced dimensionality for optimal result)
disc_set = Eigenface_f(single(F_train),Dim);
F_train = disc_set'*F_train;
F_test  = disc_set'*F_test;
F_train = F_train./(repmat(sqrt(sum(F_train.*F_train)), [Dim,1]));
F_test  = F_test./(repmat(sqrt(sum(F_test.*F_test)), [Dim,1]));

fprintf('Finish PCA at: %s\n', datetime('now'));
%% Testing

%////////////////////////////////////////////////////////////////////%    
%         Tikhonov regularized Collaborative Classifier              %
%////////////////////////////////////////////////////////////////////%

label = L2_CRC(F_train, F_test, F_train_size, NumAct, lambda);
[confusion, accuracy, CR, FR] = confusion_matrix(label, F_test_size);
fprintf('Finish calculating accuracy at: %s\n', datetime('now'));
end
