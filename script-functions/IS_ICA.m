function IS_ICA(options)

if ~isdir(options.myPostICAFolder) %make place for post-ICA files if it doesn't already exist
    mkdir(options.myPostICAFolder)
end
addpath(options.myPostICAFolder);

%document insufficient data for ica
insufficient = fopen(fullfile(options.save_dir, 'Not enough data for ICA.txt'), 'w');

%--get ttls
[subs, ttls] = Get_TTLs(options);
subs = cell2mat(subs);

%--ignore TTLs and get folders
cd(options.myFilteredFilesFolder)
files4ICA = dir('**/*.set');
files4ICA = {files4ICA.name};
addpath(genpath(options.myFilteredFilesFolder)); %need this for which() to work

%--run ICA
for file_idx = 1:numel(files4ICA)
    
    curr_file = files4ICA{file_idx};
    curr_fn = strsplit(curr_file, 'cleaned');
    
    curr_sub = strsplit(curr_file, '_');
    curr_sub = curr_sub{1};
    
    colon = strfind(curr_sub, '!');
    if ~isempty(colon) % deal with :
        curr_sub = curr_sub(1:(colon - 1));
    end
    curr_sub = str2double(curr_sub);
    
    curr_ttl_pieces = strsplit(curr_file, '_');
    curr_ttl = [];
    for idx = 2:(length(curr_ttl_pieces)-1)
        if idx == 2
            curr_ttl = strcat(curr_ttl, curr_ttl_pieces{idx});
        else
            curr_ttl = strcat(curr_ttl, '_', curr_ttl_pieces{idx});
        end
    end
    
    if ~ismember(curr_sub, subs) %use only desired subs
        continue
    elseif ismember(curr_sub, options.exclusions)  %avoid exclusions
        continue
    end
    %avoid running dyad/indiv if unnecessary
    if strcmp(options.analysis_type, 'Indiv')
        if ismember(curr_ttl, options.dyad_ttls_extended)
            continue
        end
    elseif strcmp(options.analysis_type, 'Dyad')
        if ismember(curr_ttl, options.indiv_ttls_extended)
            continue
        end
    end
    
    myCurrentOutputFile = strcat(curr_fn{1}, 'postICA.set');
    
    myCurrentInputFile = which(curr_file); %this is awesome
    %This is adjustment for win \, need to be / if linux
    %%Todo: add automatic adjustment based on system 
    newfolder_fn = strsplit(myCurrentInputFile, '\');
    newfolder_fn = newfolder_fn{numel(newfolder_fn)-1};
    newfolder_fn = strsplit(newfolder_fn, 'cleaned');
    myOutputFolder = fullfile(options.myPostICAFolder, strcat(newfolder_fn{1}, '_postICA'));

    RunICA(options, myCurrentInputFile, myCurrentOutputFile, myOutputFolder, curr_file, insufficient);
    
end
fclose(insufficient);
end


