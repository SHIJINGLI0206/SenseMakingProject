function   write_txt(file_name,data, samples_one_action)
%WRITE_TXT Summary of this function goes here
%   Detailed explanation goes here
fid = fopen(file_name,'wt');
for i = 1: size(data,1)
    label = floor((i-1)/samples_one_action) + 1;
    fprintf(fid,'%d ',label);
    for j = 1 : size(data,2)
        fprintf(fid, '%d:%.4f ',[j,data(i,j)]);
    end
    fprintf(fid,'\n');
end
fclose(fid);
end

