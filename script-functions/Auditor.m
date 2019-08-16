function Auditor(options)

%main thing this file does is fill in this log
Audit = fopen(fullfile(options.save_dir, 'Audit_of_Files_Created.txt'), 'w');
fprintf(Audit, '\nThis is %s:\n\n', options.job_name);

badshit = {'.' '..' '.DS_Store'}; %hidden files in a lot of folders. sigh.

%Which participants should be present?
all_chosen_dyads = options.Dyads;
all_chosen_dyad_ps = [(all_chosen_dyads + 1000) (all_chosen_dyads + 2000)];
chosen_dyads = unique(round(all_chosen_dyads)); %ignore .s
chosen_dyad_ps = [(chosen_dyads + 1000) (chosen_dyads + 2000)];
chosen_indivs = options.Indivs;

%Which TTLs should be present?
chosen_dyad_ttls = options.dyad_ttls.names;
chosen_indiv_ttls = options.indiv_ttls.names;
chosen_ttls = [chosen_dyad_ttls chosen_indiv_ttls];

n_chosen_dyad_ttls = length(chosen_dyad_ttls);
n_chosen_indiv_ttls = length(chosen_indiv_ttls);
n_chosen_ttls = n_chosen_dyad_ttls + n_chosen_indiv_ttls;

%clumps
chosen_clumps = {};
if sum(ismember(chosen_ttls, options.BallSqueezeTTLs)) > 0
    chosen_clumps = [chosen_clumps 'BallSqueezes'];
end
if sum(ismember(chosen_ttls, options.HeartbeatTTLs)) > 0
    chosen_clumps = [chosen_clumps 'Heartbeats'];
end
if sum(ismember(chosen_ttls, options.IndivMuTTLs)) > 0
    chosen_clumps = [chosen_clumps 'MuVideos'];
end
chosen_clumps = strcat(':_', chosen_clumps); %this  will make everything easier
n_chosen_clumps = length(chosen_clumps);

nonclump_ttls = ~ismember(chosen_ttls, options.allclumpTTLs);
nonclump_ttls = chosen_ttls(nonclump_ttls);
indiv_nonclump_ttls = ~ismember(chosen_indiv_ttls, options.allclumpTTLs);
indiv_nonclump_ttls = chosen_indiv_ttls(indiv_nonclump_ttls);
dyad_nonclump_ttls = ~ismember(chosen_dyad_ttls, options.allclumpTTLs);
dyad_nonclump_ttls = chosen_dyad_ttls(dyad_nonclump_ttls);

possible_indiv_clumps = {':_Heartbeats' ':_MuVideos'};

if sum(ismember(possible_indiv_clumps, chosen_clumps)) > 0
    indiv_clumps = ismember(possible_indiv_clumps, chosen_clumps);
    indiv_clumps = possible_indiv_clumps(indiv_clumps);
    indiv_clump_and_non = [indiv_nonclump_ttls indiv_clumps];
else
    indiv_clump_and_non = indiv_nonclump_ttls;
end

if ismember(':_BallSqueezes', chosen_clumps)
    dyad_clump_and_non = [dyad_nonclump_ttls 'BallSqueezes'];
else
    dyad_clump_and_non = dyad_nonclump_ttls;
end
all_clump_and_non = [indiv_clump_and_non dyad_clump_and_non];
n_all_clump_and_non = length(all_clump_and_non);

%for declumping
chosen_indiv_clumping_ttls = chosen_indiv_ttls(ismember(chosen_indiv_ttls, [options.HeartbeatTTLs options.IndivMuTTLs]));
chosen_dyad_clumping_ttls = chosen_dyad_ttls(ismember(chosen_dyad_ttls, options.BallSqueezeTTLs));

%%
%in EEGLAB
%Dyad
fprintf(Audit, '\n\nEEGLAB File creation:\n');
if exist(options.mySplitFilesFolder, 'dir')
    cd(options.mySplitFilesFolder);
    split_files = dir('*.set');
    split_files = {split_files.name};
    for sub = 1:numel(split_files)
        split_files{sub} = strsplit(split_files{sub}, '_');
        split_files{sub} = split_files{sub}(1,1);
    end
    split_files = [split_files{:}]; %let's not have nested cells
    split_files = str2double(split_files);
    
    missing_subs = ~ismember(all_chosen_dyad_ps, split_files);
    
    if ~isempty(missing_subs)
        missing_subs = all_chosen_dyad_ps(missing_subs);
        if ~isempty(missing_subs)
            missing_subs = num2str(missing_subs);
            fprintf(Audit, '\nIndividual files were not created from the dyadic files for participant(s) %s ', missing_subs);
        end
    else
        %print nothing
    end
    
else
    fprintf(Audit, '\nThere is no split files folder\n');
end

%Indiv
if exist(options.myIndivFilesFolder, 'dir')
    cd(options.myIndivFilesFolder);
    indiv_files = dir('*.set');
    indiv_files = {indiv_files.name};
    for sub = 1:numel(indiv_files)
        indiv_files{sub} = strsplit(indiv_files{sub}, '_');
        indiv_files{sub} = indiv_files{sub}(1,1);
    end
    indiv_files = [indiv_files{:}]; %let's not have nested cells
    indiv_files = str2double(indiv_files);
    
    missing_subs = ~ismember(chosen_indivs, indiv_files);
    
    if ~isempty(missing_subs)
        missing_subs = chosen_indivs(missing_subs);
        if ~isempty(missing_subs)
            missing_subs = num2str(missing_subs);
            fprintf(Audit, '\nAn EEGLAB file was not created for individual participant(s) %s ', missing_subs);
        end
    else
        %print nothing
    end
    
else
    fprintf(Audit, '\nThere is no Individual Files Folder\n');
end

%%
%%%segmented
fprintf(Audit, '\n\nSegmentation:\n');
if exist(options.mySegmentsFolder, 'dir')
    cd(options.mySegmentsFolder);
    fn_segments = dir();
    fn_segments = {fn_segments.name};
    fn_segments = fn_segments(~ismember(fn_segments, badshit));
    segments = strcat(':_', fn_segments); %match ttl nomenclature
    n_segments = length(segments);
    
    %TTLs
    if n_segments == n_chosen_ttls
        fprintf(Audit, '\n\nAll segments are present in segmented folder');
    elseif n_segments < n_chosen_ttls
        missing_segments = ~ismember(chosen_ttls, segments);
        missing_segments = chosen_ttls(missing_segments);
        fprintf(Audit, '\nMissing segments %s', cell2mat(missing_segments));
    end
    
    %Subjects
    for file_idx = 1:numel(fn_segments) %stupid hidden things
        curr_folder = fn_segments{file_idx};
        cd(fullfile(options.mySegmentsFolder, curr_folder));
        
        %get the subjects who are there
        present_subs = dir('*.set');
        present_subs = {present_subs.name};
        if ~isempty(present_subs)
            for sub = 1:numel(present_subs)
                present_subs{sub} = strsplit(present_subs{sub}, ':');
                present_subs{sub} = present_subs{sub}(1,1);
            end
            present_subs = [present_subs{:}]; %let's not have nested cells
            present_subs = str2double(present_subs);
            
            %Indivs
            if ismember(strcat(':_', curr_folder), chosen_indiv_ttls)
                missing_subs = ~ismember(chosen_indivs, present_subs);
                
                if ~isempty(missing_subs)
                    missing_subs = chosen_indivs(missing_subs);
                    if ~isempty(missing_subs)
                        missing_subs = num2str(missing_subs);
                        fprintf(Audit, '\nSubject(s) %s is/are missing from segment %s', missing_subs, curr_folder);
                    end
                else
                    %print nothing
                end
                
                %Dyads
            elseif ismember(strcat(':_', curr_folder), chosen_dyad_ttls)
                missing_subs = ~ismember(chosen_dyad_ps, present_subs);
                
                if ~isempty(missing_subs)
                    missing_subs = chosen_dyad_ps(missing_subs);
                    if ~isempty(missing_subs)
                        missing_subs = num2str(missing_subs);
                        fprintf(Audit, '\nSubject(s) %s is/are missing from segment %s', missing_subs, curr_folder);
                    end
                else
                    %print nothing
                end
            else
                continue
            end
        else
            fprintf(Audit, '\nSegmented Folder %s has no data in it', curr_folder);
        end
    end
    
else
    fprintf(Audit, '\nThere is no segmented files folder\n');
end

%%
%clumped
fprintf(Audit, '\n\nClumping:\n');
if exist(options.ClumpedTTlsFolder, 'dir')
    cd(options.ClumpedTTlsFolder);
    clumps = dir();
    clumps = {clumps.name};
    clumps = clumps(~ismember(clumps, badshit));
    n_clumps = length(clumps); 
    
    %TTLs
    if n_clumps == n_chosen_clumps
        fprintf(Audit, '\n\nAll clumps are present in clumped files folder');
    elseif n_clumps < n_chosen_clumps
        missing_clumps = ~ismember(chosen_clumps, clumps);
        missing_clumps = chosen_clumps(missing_clumps);
        fprintf(Audit, '\nMissing clumps %s', cell2mat(missing_clumps));
    end
    
    %Subjects
    for file_idx = 1:numel(clumps) %stupid hidden things
        curr_folder = clumps{file_idx};
        cd(fullfile(options.ClumpedTTlsFolder, curr_folder));
        
        %get the subjects who are there
        present_subs = dir('*.set');
        present_subs = {present_subs.name};
        if ~isempty(present_subs)
            for sub = 1:numel(present_subs)
                present_subs{sub} = strsplit(present_subs{sub}, '_');
                present_subs{sub} = present_subs{sub}(1,1);
            end
            present_subs = [present_subs{:}]; %let's not have nested cells
            present_subs = str2double(present_subs);
            
            %Indivs
            if ismember(strcat(':_', curr_folder), possible_indiv_clumps)
                missing_subs = ~ismember(chosen_indivs, present_subs);
                
                if ~isempty(missing_subs)
                    missing_subs = chosen_indivs(missing_subs);
                    if ~isempty(missing_subs)
                        missing_subs = num2str(missing_subs);
                        fprintf(Audit, '\nSubject(s) %s is/are missing from clump %s', missing_subs, curr_folder);
                    end
                else
                    %print nothing
                end
                
                %Dyads
            elseif strcmp(curr_folder, 'BallSqueezes')
                missing_subs = ~ismember(chosen_dyad_ps, present_subs);
                
                if ~isempty(missing_subs)
                    missing_subs = chosen_dyad_ps(missing_subs);
                    if ~isempty(missing_subs)
                        missing_subs = num2str(missing_subs);
                        fprintf(Audit, '\nSubject(s) %s is/are missing from clump %s', missing_subs, curr_folder);
                    end
                else
                    %print nothing
                end
            else
                continue
            end
        else
            fprintf(Audit, '\nClumped Files Folder %s has no data in it', curr_folder);
        end
    end
    
else
    fprintf(Audit, '\nThere is no clumped files folder\n');
end

%%
%filtered
fprintf(Audit, '\n\nFiltering:\n');
if exist(options.myFilteredFilesFolder, 'dir')
    cd(options.myFilteredFilesFolder);
    segments = dir();
    segments = {segments.name};
    segments = segments(~ismember(segments, badshit));
    n_segments = length(segments); 
    
    %TTLs
    if n_segments == n_all_clump_and_non
        fprintf(Audit, '\n\nAll segments are present in filtered files folder');
    elseif n_segments < n_all_clump_and_non
        %need to deal with naming
        compare_segs = nonclump_ttls;
        compare_segs = strcat(compare_segs, '_cleaned');
        missing_segs = ~ismember(compare_segs, strcat(':_', segments));
        missing_segs = compare_segs(missing_segs);
        
        compare_clumps = chosen_clumps;
        compare_clumps = strcat(compare_clumps, '_cleaned');
        missing_clumps = ~ismember(compare_clumps, strcat(':_', segments));
        missing_clumps = compare_clumps(missing_clumps);
        
        missing = [missing_segs missing_clumps];
        fprintf(Audit, '\nMissing filtered files: %s', cell2mat(missing));
    end
    
    %Subjects
    for file_idx = 1:numel(segments) %stupid hidden things
        curr_folder = segments{file_idx};
        cd(fullfile(options.myFilteredFilesFolder, curr_folder));
        
        %get the subjects who are there
        present_subs = dir('*.set');
        present_subs = {present_subs.name};
        if ~isempty(present_subs)
            for sub = 1:numel(present_subs)
                present_subs{sub} = strsplit(present_subs{sub}, '_');
                present_subs{sub} = present_subs{sub}(1,1);
            end
            present_subs = [present_subs{:}]; %let's not have nested cells
            if sum(isnan(str2double(present_subs))) > 0
                for sub = 1:numel(present_subs)
                    present_subs{sub} = strsplit(present_subs{sub}, ':');
                    present_subs{sub} = present_subs{sub}(1,1);
                end
                present_subs = [present_subs{:}];
                present_subs = str2double(present_subs);
            else
                present_subs = str2double(present_subs);
            end
            
            %Indivs
            if ismember(strcat(':_', curr_folder), strcat(indiv_clump_and_non, '_cleaned'))
                missing_subs = ~ismember(chosen_indivs, present_subs);
                
                if ~isempty(missing_subs)
                    missing_subs = chosen_indivs(missing_subs);
                    if ~isempty(missing_subs)
                        missing_subs = num2str(missing_subs);
                        fprintf(Audit, '\nSubject(s) %s is/are missing filtered file %s', missing_subs, curr_folder);
                    end
                else
                    %print nothing
                end
                
                %Dyads
            elseif ismember(strcat(':_', curr_folder), strcat(dyad_clump_and_non, '_cleaned'))
                missing_subs = ~ismember(chosen_dyad_ps, present_subs);
                
                if ~isempty(missing_subs)
                    missing_subs = chosen_dyad_ps(missing_subs);
                    if ~isempty(missing_subs)
                        missing_subs = num2str(missing_subs);
                        fprintf(Audit, '\nSubject(s) %s is/are missing filtered file %s', missing_subs, curr_folder);
                    end
                else
                    %print nothing
                end
            else
                continue
            end
        else
            fprintf(Audit, '\nFiltered Folder %s has no data in it', curr_folder);
        end
    end
else
    fprintf(Audit, '\nThere is no filtered files folder\n');
end

%%
%ICA
fprintf(Audit, '\n\nICA:\n');
if exist(options.myPostICAFolder, 'dir')
    cd(options.myPostICAFolder);
    segments = dir();
    segments = {segments.name};
    segments = segments(~ismember(segments, badshit));
    n_segments = length(segments);
    
    %TTLs
    if n_segments == n_all_clump_and_non
        fprintf(Audit, '\n\nAll segments are present in Post-ICA files folder');
    elseif n_segments < n_all_clump_and_non
        %need to deal with naming
        compare_segs = nonclump_ttls;
        compare_segs = strcat(compare_segs, '__postICA');
        missing_segs = ~ismember(compare_segs, strcat(':_', segments));
        missing_segs = compare_segs(missing_segs);
        
        compare_clumps = chosen_clumps;
        compare_clumps = strcat(compare_clumps, '__postICA');
        missing_clumps = ~ismember(compare_clumps, strcat(':_', segments));
        missing_clumps = compare_clumps(missing_clumps);
        
        missing = [missing_segs missing_clumps];
        fprintf(Audit, '\nMissing Post-ICA files %s', cell2mat(missing));
    end
    
    %Subjects
    for file_idx = 1:numel(segments) %stupid hidden things
        curr_folder = segments{file_idx};
        cd(fullfile(options.myPostICAFolder, curr_folder));
        
        %get the subjects who are there
        present_subs = dir('*.set');
        present_subs = {present_subs.name};
        if ~isempty(present_subs)
            for sub = 1:numel(present_subs)
                present_subs{sub} = strsplit(present_subs{sub}, '_');
                present_subs{sub} = present_subs{sub}(1,1);
            end
            present_subs = [present_subs{:}]; %let's not have nested cells
            if sum(isnan(str2double(present_subs))) > 0
                for sub = 1:numel(present_subs)
                    present_subs{sub} = strsplit(present_subs{sub}, ':');
                    present_subs{sub} = present_subs{sub}(1,1);
                end
                present_subs = [present_subs{:}];
                present_subs = str2double(present_subs);
            else
                present_subs = str2double(present_subs);
            end

            %Indivs
            if ismember(strcat(':_', curr_folder), strcat(indiv_clump_and_non, '__postICA'))
                missing_subs = ~ismember(chosen_indivs, present_subs);
                
                if ~isempty(missing_subs)
                    missing_subs = chosen_indivs(missing_subs);
                    if ~isempty(missing_subs)
                        missing_subs = num2str(missing_subs);
                        fprintf(Audit, '\nSubject(s) %s is/are missing post-ICA file %s', missing_subs, curr_folder);
                    end
                else
                    %print nothing
                end
                
                %Dyads
            elseif ismember(strcat(':_', curr_folder), strcat(dyad_clump_and_non, '__postICA'))
                missing_subs = ~ismember(chosen_dyad_ps, present_subs);
                
                if ~isempty(missing_subs)
                    missing_subs = chosen_dyad_ps(missing_subs);
                    if ~isempty(missing_subs)
                        missing_subs = num2str(missing_subs);
                        fprintf(Audit, '\nSubject(s) %s is/are missing post-ICA file %s', missing_subs, curr_folder);
                    end
                else
                    %print nothing
                end
            else
                continue
            end
        else
            fprintf(Audit, '\nPost-ICA Folder %s has no data in it', curr_folder);
        end
    end
else
    fprintf(Audit, '\nThere is no post-ICA files folder\n');
end

%%
%Artifact removal
fprintf(Audit, '\n\nArtifact Removal:\n');
if exist(options.PostBlinkFolder, 'dir')
    cd(options.PostBlinkFolder);
    segments = dir();
    segments = {segments.name};
    segments = segments(~ismember(segments, badshit));
    n_segments = length(segments);
    
    %TTLs
    if n_segments == n_all_clump_and_non
        fprintf(Audit, '\n\nAll segments are present in Post-Artifact Removal files folder');
    elseif n_segments < n_all_clump_and_non
        %need to deal with naming
        compare_segs = nonclump_ttls;
        compare_segs = strcat(compare_segs, '__Post_Blinks');
        missing_segs = ~ismember(compare_segs, strcat(':_', segments));
        missing_segs = compare_segs(missing_segs);
        
        compare_clumps = chosen_clumps;
        compare_clumps = strcat(compare_clumps, '__Post_Blinks');
        missing_clumps = ~ismember(compare_clumps, strcat(':_', segments));
        missing_clumps = compare_clumps(missing_clumps);
        
        missing = [missing_segs missing_clumps];
        fprintf(Audit, '\nMissing Post-Artifact Removal files %s', cell2mat(missing));
    end
    
    %Subjects
    for file_idx = 1:numel(segments) %stupid hidden things
        curr_folder = segments{file_idx};
        cd(fullfile(options.PostBlinkFolder, curr_folder));
        
        %get the subjects who are there
        present_subs = dir('*.set');
        present_subs = {present_subs.name};
        if ~isempty(present_subs)
            for sub = 1:numel(present_subs)
                present_subs{sub} = strsplit(present_subs{sub}, '_');
                present_subs{sub} = present_subs{sub}(1,1);
            end
            present_subs = [present_subs{:}]; %let's not have nested cells
            if sum(isnan(str2double(present_subs))) > 0
                for sub = 1:numel(present_subs)
                    present_subs{sub} = strsplit(present_subs{sub}, ':');
                    present_subs{sub} = present_subs{sub}(1,1);
                end
                present_subs = [present_subs{:}];
                present_subs = str2double(present_subs);
            else
                present_subs = str2double(present_subs);
            end

            %Indivs
            if ismember(strcat(':_', curr_folder), strcat(indiv_clump_and_non, '__Post_Blinks'))
                missing_subs = ~ismember(chosen_indivs, present_subs);
                
                if ~isempty(missing_subs)
                    missing_subs = chosen_indivs(missing_subs);
                    if ~isempty(missing_subs)
                        missing_subs = num2str(missing_subs);
                        fprintf(Audit, '\nSubject(s) %s is/are missing post-Artifact Rejection file %s', missing_subs, curr_folder);
                    end
                else
                    %print nothing
                end
                
                %Dyads
            elseif ismember(strcat(':_', curr_folder), strcat(dyad_clump_and_non, '__Post_Blinks'))
                missing_subs = ~ismember(chosen_dyad_ps, present_subs);
                
                if ~isempty(missing_subs)
                    missing_subs = chosen_dyad_ps(missing_subs);
                    if ~isempty(missing_subs)
                        missing_subs = num2str(missing_subs);
                        fprintf(Audit, '\nSubject(s) %s is/are missing post-Artifact Rejection file %s', missing_subs, curr_folder);
                    end
                else
                    %print nothing
                end
            else
                continue
            end
        else
            fprintf(Audit, '\nPost-Artifact Rejection Folder %s has no data in it', curr_folder);
        end
    end
else
    fprintf(Audit, '\nThere is no post-artifact rejection folder\n');
end

%%
%De-clumped
fprintf(Audit, '\n\nDe-Clumping:\n');
if exist(options.DeclumpedFiles, 'dir')
    cd(options.DeclumpedFiles);
    segments = dir();
    segments = {segments.name};
    segments = segments(~ismember(segments, badshit));
    n_segments = length(segments);
    
    %TTLs
    if n_segments == length(options.allclumpTTLs)
        fprintf(Audit, '\n\nAll de-clumped segments are present in the de-clumped folder');
    elseif n_segments < length(options.allclumpTTLs)
        missing_segments = ~ismember(options.allclumpTTLs, segments);
        missing_segments = options.allclumpTTLs(missing_segments);
        fprintf(Audit, '\nMissing de-clumped segments %s', cell2mat(missing_segments));
    end
    
    %Subjects
    for file_idx = 1:numel(segments) %stupid hidden things
        curr_folder = segments{file_idx};
        cd(fullfile(options.DeclumpedFiles, curr_folder));
        
        %get the subjects who are there
        present_subs = dir('*.set');
        present_subs = {present_subs.name};
        if ~isempty(present_subs)
            for sub = 1:numel(present_subs)
                present_subs{sub} = strsplit(present_subs{sub}, ':');
                present_subs{sub} = present_subs{sub}(1,1);
            end
            present_subs = [present_subs{:}]; %let's not have nested cells
            present_subs = str2double(present_subs);
            
            %Indivs
            if ismember(curr_folder, chosen_indiv_clumping_ttls)
                missing_subs = ~ismember(chosen_indivs, present_subs);
                
                if ~isempty(missing_subs)
                    missing_subs = chosen_indivs(missing_subs);
                    if ~isempty(missing_subs)
                        missing_subs = num2str(missing_subs);
                        fprintf(Audit, '\nSubject(s) %s is/are missing from de-clumped segment %s', missing_subs, curr_folder);
                    end
                else
                    %print nothing
                end
                
                %Dyads
            elseif ismember(curr_folder, chosen_dyad_clumping_ttls)
                missing_subs = ~ismember(chosen_dyad_ps, present_subs);
                
                if ~isempty(missing_subs)
                    missing_subs = chosen_dyad_ps(missing_subs);
                    if ~isempty(missing_subs)
                        missing_subs = num2str(missing_subs);
                        fprintf(Audit, '\nSubject(s) %s is/are missing from de-clumped segment %s', missing_subs, curr_folder);
                    end
                else
                    %print nothing
                end
            else
                continue
            end
        else
            fprintf(Audit, '\nDe-Clumped Folder %s has no data in it', curr_folder);
        end
    end
    
    
else
    fprintf(Audit, '\nThere is no declumpled files folder\n');
end

%%
%Epochs removed
fprintf(Audit, '\n\nEpoch Removal:\n');
if exist(options.FinalSegments, 'dir')
    cd(options.FinalSegments);
    segments = dir();
    segments = {segments.name};
    segments = segments(~ismember(segments, badshit));
    n_segments = length(segments);
    
    %TTLs
    if n_segments == n_chosen_ttls
        fprintf(Audit, '\n\nAll segments are present in the final folder');
    elseif n_segments < n_chosen_ttls
        missing_segments = ~ismember(chosen_ttls, segments);
        missing_segments = chosen_ttls(missing_segments);
        fprintf(Audit, '\nMissing final files for segments %s', cell2mat(missing_segments));
    end
    
    %Subjects
    for file_idx = 1:numel(segments) %stupid hidden things
        curr_folder = segments{file_idx};
        cd(fullfile(options.FinalSegments, curr_folder));
        
        %get the subjects who are there
        present_subs = dir('*.set');
        present_subs = {present_subs.name};
        if ~isempty(present_subs)
            for sub = 1:numel(present_subs)
                present_subs{sub} = strsplit(present_subs{sub}, ':');
                present_subs{sub} = present_subs{sub}(1,1);
            end
            present_subs = [present_subs{:}]; %let's not have nested cells
            present_subs = str2double(present_subs);
            
            %Indivs
            if ismember(curr_folder, chosen_indiv_ttls)
                missing_subs = ~ismember(chosen_indivs, present_subs);
                
                if ~isempty(missing_subs)
                    missing_subs = chosen_indivs(missing_subs);
                    if ~isempty(missing_subs)
                        missing_subs = num2str(missing_subs);
                        fprintf(Audit, '\nSubject(s) %s is/are missing from the final folder for segment %s', missing_subs, curr_folder);
                    end
                else
                    %print nothing
                end
                
                %Dyads
            elseif ismember(curr_folder, chosen_dyad_ttls)
                missing_subs = ~ismember(chosen_dyad_ps, present_subs);
                
                if ~isempty(missing_subs)
                    missing_subs = chosen_dyad_ps(missing_subs);
                    if ~isempty(missing_subs)
                        missing_subs = num2str(missing_subs);
                        fprintf(Audit, '\nSubject(s) %s is/are missing from the final folder for segment %s', missing_subs, curr_folder);
                    end
                else
                    %print nothing
                end
            else
                continue
            end
        else
            fprintf(Audit, '\nFinal Folder %s has no data in it', curr_folder);
        end
    end
    
else
    fprintf(Audit, '\nThere is no final segments folder\n');
end

end