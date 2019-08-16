function Pre_ICA_clumping(options)

if ~isdir(options.ClumpedTTlsFolder)
    mkdir(options.ClumpedTTlsFolder)
end
addpath(options.ClumpedTTlsFolder);

%--get right TTLs
[subs, ttls] = Get_TTLs(options);

%--clump
for sub_idx = 1:length(subs)
    
    curr_sub = subs{sub_idx};
    
    if ismember(curr_sub, options.exclusions)
        continue
    end
    
    if length(curr_sub) > 1  %not really sure why this is now needed...
        curr_sub = curr_sub(sub_idx);
    end
    
    fprintf('\nClumping: Working on subject: %d now\n\n', curr_sub);

    %--get the ball squeeze ttls present in this data
    BallSqueeze = ttls(ismember(ttls, options.BallSqueezeTTLs));
    if ~isempty(BallSqueeze) %no need to do it if the clumps aren't in the data
        myCurrentOutputFile = strcat(num2str(curr_sub), '_BallSqueezes', '.set'); 
        BallSqueeze_folder = fullfile(options.ClumpedTTlsFolder, 'BallSqueezes');
        if ~isdir(BallSqueeze_folder)
            mkdir(BallSqueeze_folder)
        end
        addpath(BallSqueeze_folder);
        %clump
        TTL_clump(BallSqueeze, curr_sub, myCurrentOutputFile, BallSqueeze_folder, options);
    end
    
    %-get heartbeat ttls present in this data
    Heartbeat = ttls(ismember(ttls, options.HeartbeatTTLs));
    if ~isempty(Heartbeat)
        myCurrentOutputFile = strcat(num2str(curr_sub), '_Heartbeats', '.set');
        Heartbeat_folder = fullfile(options.ClumpedTTlsFolder, 'Heartbeats');
        if ~isdir(Heartbeat_folder)
            mkdir(Heartbeat_folder)
        end
        addpath(Heartbeat_folder);
        %clump
        TTL_clump(Heartbeat, curr_sub, myCurrentOutputFile, Heartbeat_folder, options);
    end
    
    %-get mu ttls from videos
    IndivMu = ttls(ismember(ttls, options.IndivMuTTLs));
    if ~isempty(IndivMu)
        myCurrentOutputFile = strcat(num2str(curr_sub), '_MuVideos', '.set');
        MuVideos_folder = fullfile(options.ClumpedTTlsFolder, 'MuVideos');
        if ~isdir(MuVideos_folder)
            mkdir(MuVideos_folder)
        end
        addpath(MuVideos_folder);
        %clump
        TTL_clump(IndivMu, curr_sub, myCurrentOutputFile, MuVideos_folder, options);
    end
    
end





