
subset =1;
NumAct = 8;
 
%% plot classification accuracy bar 
CR_SVM_Avg = sum(CR);
str = action_names((subset - 1)*NumAct + 1 : subset*NumAct );
bar(CR_SVM_Avg,0.4);
set(gca, 'XTickLabel',str, 'XTick',1:numel(str));
xlabel('Actions','FontSize',14,'FontWeight','bold','Color','b')
ylabel('Accuracy (%)','FontSize',14,'FontWeight','bold','Color','b')
title('Cross Random CRC Classification Accuracy','FontSize',16,'Color', 'b')