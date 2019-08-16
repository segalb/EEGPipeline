function Artifact_Removal(options)

if ~isdir(options.PostBlinkFolder) %make place for post-blink files if it doesn't already exist
    mkdir(options.PostBlinkFolder)
end
addpath(options.PostBlinkFolder);

%--get ttls
[subs, ttls] = Get_TTLs(options);
subs = cell2mat(subs);

%--ignore TTLs and get folders
cd(options.myPostICAFolder)
files2clean = dir('**/*.set');
files2clean = {files2clean.name};
addpath(genpath(options.myPostICAFolder)); %need this for which() to work

%--document components
components_log = fopen(fullfile(options.save_dir, 'Component_Log.txt'), 'w');

%--run Artifact Removal
for file_idx = 1:numel(files2clean)

    curr_file = files2clean{file_idx};
    curr_fn = strsplit(curr_file, 'post');
    
    curr_sub = strsplit(curr_file, '_');
    curr_sub = curr_sub{1};
    
    colon = strfind(curr_sub, ':');
    if ~isempty(colon) % deal with :
        curr_sub = curr_sub(1:(colon - 1));
    end
    curr_sub = str2double(curr_sub);
    
    curr_ttl = strsplit(curr_file, '_');
    curr_ttl = curr_ttl{2};

    if ~ismember(curr_sub, subs) %use only desired subs
        continue
    elseif ismember(curr_sub, options.exclusions)  %avoid exclusions
        continue
    end
    %avoid running dyad/indiv if unnecessary (may want to put into other
    %files too)
    if strcmp(options.analysis_type, 'Indiv')
        if ismember(curr_ttl, options.dyad_ttls_extended)
            continue
        end
    elseif strcmp(options.analysis_type, 'Dyad')
        if ismember(curr_ttl, options.indiv_ttls_extended)
            continue
        end
    end

    myCurrentOutputFile = strcat(curr_fn{1}, 'Post_Blinks.set');
    myCurrentInputFile = which(curr_file); %this is awesome
    
    newfolder_fn = strsplit(myCurrentInputFile, '/');
    newfolder_fn = newfolder_fn{numel(newfolder_fn)-1};
    newfolder_fn = strsplit(newfolder_fn, 'post');
    myOutputFolder = fullfile(options.PostBlinkFolder, strcat(newfolder_fn{1}, 'Post_Blinks'));

    %--remove artifacts
    Remove_Artifacts(options, myCurrentInputFile, myCurrentOutputFile, myOutputFolder, components_log);

end
fclose(components_log);
end





