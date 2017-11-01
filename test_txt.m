
% write depth data into txt file with fixed format
X_train = F_train';
y_test = F_test';
write_txt('X_train.txt',X_train,24);
write_txt('y_test.txt',y_test,8);
