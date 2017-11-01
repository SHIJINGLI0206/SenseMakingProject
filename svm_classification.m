
[train_label, train_scale_inst] = libsvmread('X_train.txt');
[test_label, test_scale_inst] = libsvmread('y_test.txt');
model = svmtrain(train_label, train_scale_inst, '-s 1 -t 0 -c 1 -g 0.07 -b 1');
[predict_label, accuracy, prob_estimates] = svmpredict(test_label, test_scale_inst, model, '-b 1');

CR_SVM = zeros(24,1);
for i = 1 : size(predict_label,1)
   m = floor((i-1)/8) + 1;
   CR_SVM(m) = CR_SVM(m) + (predict_label(i) == m);  
end
CR_SVM = CR_SVM ./ 8;

str={'a01';'a02';'a03';'a04';'a05';'a06';'a07';'a09';'a10';'a11';'a12';'a13';'a14';'a15';'a16';'a17';'a18';'a19';'a20';'a21';'a22';'a24';'a25';'a26'};

bar(CR_SVM,0.4);
set(gca, 'XTickLabel',str, 'XTick',1:numel(str));
xlabel('Actions','FontSize',14,'FontWeight','bold','Color','b')
ylabel('Accuracy (%)','FontSize',14,'FontWeight','bold','Color','b')
title('SVM Classification Accuracy','FontSize',16,'Color', 'b')


