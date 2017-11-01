
[heart_scale_label, heart_scale_inst] = libsvmread('X_train.txt');
model = svmtrain(heart_scale_label, heart_scale_inst, '-c 1 -g 0.07 -b 1');

[predict_label, accuracy, prob_estimates] = svmpredict(heart_scale_label, heart_scale_inst, model, '-b 1');