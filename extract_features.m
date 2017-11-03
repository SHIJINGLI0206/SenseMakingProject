function [TotalFeature, OneActionSample] = extract_features(group_actions)
%EXTRACT_FEATURES Summary of this function goes here
%   Detailed explanation goes here

file_dir = 'Data\';
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
max_experiment = 4;  % default 3;  % maximum number of experiments performed by one subject
lambda = 0.001;      % Tikhonov regularization parameter (parameter tuning for the optimal value)
frame_remove = 5;    % remove the first and last five frames (mostly the subject is in stand-still position in these frames)

T = 3;               % number of samples of each subject for training

ActionSets = ["AS1","AS2","AS3"];
ActionSet = ActionSets(group_actions);  % group_actions = 1,2,3


fprintf('Action set: %s; %d training sample(s) of each subject\n', ActionSet, T);
fprintf('Start Work at: %s\n', datetime('now'));

switch ActionSet
    case 'AS1'
        subset = 1;
        fix_size_front = round([100;50]/2); fix_size_side = round([100;82]/2); fix_size_top = round([82;47]/2);
        %fix_size_front = [100;50]; fix_size_side = [100;82]; fix_size_top = [82;47];
        % the fixed size of each projection view is calculated as the
        % average size of DMMs of all samples, here we did not optimize the
        % sizes.
        % 
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
end

