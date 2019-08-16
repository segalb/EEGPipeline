function RidTTL(fn_xlsx, directory)

%HOW TO USE THIS CODE: OPEN RidTTL_loop.m and read the directions there!

cd(directory); %takes you to folder with path you had specified

[num,txt,raw]=xlsread(fn_xlsx);%read Excel sheet and store values into a cell array called raw
len=length(raw);
col1= raw(12:len,1);
col2= raw(12:len,2);
col3= raw(12:len,3); %not sure if it goes to 197 for all files??
col4= raw(12:len,4);
col5= raw(12:len,5);
col6= raw(12:len,6);

col6(cellfun(@isnan, col6)) = {[]};

val=length(col3);
col7=cell(val-1,1);

for i=1:(val-1)
    a=col3{i+1}-col3{i}; %subtracts consecutive values from one another
    col7{i}=a; %stores differences between values in a cell array called "col7"
end

k=find(cell2mat(col7)~=1); %finds indices where difference does not equal to 1 and stores into vector "k"

newcol1=cell(length(k)+1,1);
newcol2=cell(length(k)+1,1);
newcol3=cell(length(k)+1,1);
newcol4=cell(length(k)+1,1);
newcol5=cell(length(k)+1,1);
newcol6=cell(length(k)+1,1);

newcol1(1:length(k),1)=col1(k); %using indices stored in "k", picks up the values in cell arrays
newcol1(end,1)=col1(end);
newcol2(1:length(k),1)=col2(k);
newcol2(end,1)=col2(end);
newcol3(1:length(k),1)=col3(k);
newcol3(end,1)=col3(end);
newcol4(1:length(k),1)=col4(k);
newcol4(end,1)=col4(end);
newcol5(1:length(k),1)=col5(k);
newcol5(end,1)=col5(end);
newcol6(1:length(k),1)=col6(k);
newcol6(end,1)=col6(end);

h=length(k)+12;
C=cell(h,6);

C(1:11,1:6)=raw(1:11,1:6);
C(12:h,1)=newcol1;
C(12:h,2)=newcol2;
C(12:h,3)=newcol3;
C(12:h,4)=newcol4;
C(12:h,5)=newcol5;
C(12:h,6)=newcol6;

C = killnans(C);
          
output_FN = strsplit(fn_xlsx,'.xlsx');
output_FN = [output_FN{1} '.txt'];
output_FN = fullfile(directory,output_FN);
%writetable(T,output_FN,'WriteVariableNames',false) 
%write table is having trouble with extra commas, using manual file printing

fileID = fopen(output_FN,'w');
for i = 1:size(C,1)
    for j = 1:size(C,2)
        cell2print = C{i,j};
        if isnumeric(cell2print) %change to char for printing, don't take sci notation 
            cell2print = sprintf('%.0f',cell2print); 
        end
        if sum(cellfun(@isempty,C(i,j+1:end))) ~= numel(C(i,j+1:end)) %only add a comma if the remaining cells in the current row are all empty 
            cell2print = [cell2print ','];
        end
        fprintf(fileID,'%s',cell2print);
    end
    fprintf(fileID,'\r\n');
end
fclose(fileID);

vmrk_output_FN = strsplit(output_FN,'.txt');
vmrk_output_FN = [vmrk_output_FN{1} '.vmrk'];
movefile(output_FN,vmrk_output_FN)

end