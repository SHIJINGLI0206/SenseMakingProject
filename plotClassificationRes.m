% fixed size test result
myCR = CR.*100;
str={'a01';'a02';'a03';'a04';'a05';'a06';'a07';'a09';'a10';'a11';'a12';'a13';'a14';'a15';'a16';'a17';'a18';'a19';'a20';'a21';'a22';'a24';'a25';'a26'};
set(gca, 'XTickLabel',str, 'XTick',1:numel(str));
bar(myCR,0.4);