function RidTTL_loop(options)

%%% HOW TO USE THIS CODE:
% Note: scroll down past these directions to see a description of what the
% code does

%%% STEP 1:
% in the code below, set "subjects" equal to the subject numbers in your
% sample.
% ex. subjects = [1 2 3 4 5];
% you don't need commas, but you do need to put the numbers between
% brackets. You can also use : to indicate "through" as in "1 through 5"
% ex. subjects = [1:5];       %this will be the same as the previous example
% Your subject numbers have to be identical to the names of the .xlsx files
% you are editing.
% NOTE: if you have letters in your file names ALL of your file names have
% to be in quotation marks and you need to use curly brackets
% ex. subjects = {"1" "2b" "3"};

%%% STEP 2:
% in the code below, set "directory" equal to the folder containing your
% .xlsx files.
% ex. directory = '/Users/Jeremy/Desktop'
% note that the file path has to be between quotation marks
% remember that on Macs file paths use forward slashes: /
% on PCs they use back slashes: \
% ex. directory = 'C:Jeremy\Desktop'

%%% STEP 3:
% Now run this code! (i.e. by pressing the green play button that says
% "Run" above
% Note: as long as both codes are in the same folder you won't even have to
% open RidTTL.m

%%% HOW THIS CODE WORKS
% This is just a simple loop that calls the function in the file RidTTL.m.
% I wrote this so that you don't have to run each file individually (though
% you do have to make the .xlsxs individually). So you tell it where to go
% and the numbers of the files it's looking for and it will perform the
% RidTTL function on each of those files.
% Lila wrote the RidTTL function. It simply looks at the timepoints of all
% the markers in the file and takes out any timepoints that are exactly 1
% timepoint after the preceeding one, as that seems to be where DirectRT
% puts the extra TTLs. It will occasionally miss an extra TTL, but it
% doesn't seem to get rid of good ones.

directory = options.myRawFilesFolder;

old_VMRK_dir = fullfile(directory, 'old_VMRKs');
if ~isdir(old_VMRK_dir)
    mkdir(old_VMRK_dir)
end
addpath(old_VMRK_dir);

cd(directory);

subjects = dir('*.xlsx');
subjects = {subjects.name};

for sub_idx = 1:numel(subjects)
    fn_xlsx = subjects{sub_idx};
    
    fprintf('Now working on file: %s \n', fn_xlsx);
    
    RidTTL(fn_xlsx, directory);
end

end