function de_clumping(options)

if ~isdir(options.DeclumpedFiles) %make place for declumped files if it doesn't already exist
    mkdir(options.DeclumpedFiles)
end
addpath(options.DeclumpedFiles);

%--ignore TTLs and get folders
cd(options.PostBlinkFolder)
files2declump = dir('**/*.set');
files2declump = {files2declump.name};
addpath(genpath(options.PostBlinkFolder)); %need this for which() to work

if strcmp(options.analysis_type, 'Indiv')
    clump_names = {'Heartbeats', 'MuVideos', 'BaselineTTLs'};
    inclusions = options.Indivs;
elseif strcmp(options.analysis_type, 'Dyad')
    clump_names = {'BallSqueezes'};
    inclusions = [options.Dyads + 1000 options.Dyads + 2000];
else
    clump_names = {'BallSqueezes', 'Heartbeats', 'MuVideos', 'BaselineTTLs'};
    inclusions = unique([options.Indivs options.Dyads + 1000 options.Dyads + 2000]);
end

%--declump
for file_idx = 1:numel(files2declump)
    
    curr_file = files2declump{file_idx};
    
    clump_id = strsplit(curr_file, '_'); %works since clump names don't have
    curr_sub = clump_id{1};
    clump_id = clump_id{2}; %yay consistent nomenclature

    if ismember(clump_id, clump_names)
        
        if ~ismember(str2double(curr_sub), options.exclusions)
            if ismember(str2double(curr_sub), inclusions)
                
                curr_fn = strsplit(curr_file, 'Post');
                
                myCurrentInputFile = which(curr_file); %this is awesome
                
                if exist(myCurrentInputFile, 'file')
                    
                    seg_start = 0;
                    
                    if strcmp(clump_id, 'BallSqueezes')
                        ttls = {'S150', 'S151', 'S152', 'S153'};
                        seg_ends = [30 30 30 30];
                        seg_names = options.BallSqueezeTTLs;
                    elseif strcmp(clump_id, 'Heartbeats')
                        ttls = {'S 15', 'S 25', 'S 35', 'S 45'};
                        seg_ends = [15 25 35 45];
                        seg_names = options.HeartbeatTTLs;
                    elseif strcmp(clump_id, 'MuVideos')
                        ttls = {'S101', ...
                            'S102', ...
                            'S103', ...
                            'S104', ...
                            'S105', ...
                            'S106', ...
                            'S111', ...
                            'S112', ...
                            'S113', ...
                            'S114', ...
                            'S115', ...
                            'S116', ...
                            'S117', ...
                            'S118', ...
                            'S119', ...
                            'S120', ...
                            'S121', ...
                            'S122', ...
                            'S123', ...
                            'S124', ...
                            'S127', ...
                            'S128', ...
                            'S129', ...
                            'S130', ...
                            'S131', ...
                            'S132', ...
                            'S133', ...
                            'S134', ...
                            'S251', 'S252'};
                        seg_ends = [10 10 10 10 10 10 ...
                            2 2 2 2 2 2 ...
                            2 2 2 2 2 2 2 2 ...
                            2 2 2 2 2 2 2 2 ...
                            60 80];
                        seg_names = options.IndivMuTTLs;
                    end
                    
                    de_clumper(options, myCurrentInputFile, seg_start, ttls, seg_ends, seg_names, curr_sub);
                
                else
                    continue
                end
            end
        end
        
    else
        
        %not part of a clump, just save it over as final
        
    end
    
end

end