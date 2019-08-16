function Run_Artifact_Rejection(options)

if ~isdir(options.PostARFFolder) %make place for post-ARF files if it doesn't already exist
    mkdir(options.PostARFFolder)
end
addpath(options.PostARFFolder);

%--ignore TTLs and get folders
cd(options.myPostICAFolder)
files2clean = dir('**/*.set');
files2clean = {files2clean.name};

%--run Artifact Rejection
for file_idx = 1:numel(files2clean)

    curr_file = files2clean{file_idx};
    
    curr_fn = strsplit(curr_file, 'post');
    myCurrentOutputFile = strcat(curr_fn{1}, 'postARF.set');
    
    myCurrentInputFile = which(curr_file); %this is awesome
    
    newfolder_fn = strsplit(myCurrentInputFile, '/');
    newfolder_fn = newfolder_fn{numel(newfolder_fn)-1};
    newfolder_fn = strsplit(newfolder_fn, 'post');
    myOutputFolder = fullfile(options.PostARFFolder, strcat(newfolder_fn{1}, 'postARF'));

    Artifact_Rejection(options, myCurrentInputFile, myCurrentOutputFile, myOutputFolder);

end

end





