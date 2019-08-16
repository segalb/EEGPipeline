function TTL_clump(clump, curr_sub, myCurrentOutputFile, myOutputFolder, options)

ALLEEG = [];

for idx = 1:length(clump)
    curr_ttl = clump{idx};
    
    myCurrentInputFile = strcat(num2str(curr_sub), curr_ttl, '.set');
    myCurrentFolder = fullfile(options.mySegmentsFolder, strcat(extractAfter(curr_ttl, ':_')));
    addpath(myCurrentFolder)
    if exist(myCurrentInputFile, 'file')
        [EEG] = pop_loadset('filename', myCurrentInputFile,'filepath', myCurrentFolder);
        ALLEEG = [ALLEEG EEG];
    else
        continue
    end
end

if length(ALLEEG) > 1
    try  %sometimes some segments have fewer channels =(
        EEG = pop_mergeset(ALLEEG, 1:length(ALLEEG));
    catch  %THIS WILL NOT CATCH IT IF THE TWO MAX # OF CHANNElS HAVE DIFF CHANNELS
        %find out how many channels the most have
        chan_ns = [ALLEEG.nbchan];
        max_chans = max(chan_ns);
        
        %find what's missing
        missing_chans = chan_ns < max_chans;
        missing_chans_locs = find(missing_chans);
        full_chan = find(chan_ns == max_chans);
        
        %present
        present_chans = cell(1, numel(ALLEEG));
        for dset = 1:numel(ALLEEG)
            present_chans{dset} = {ALLEEG(dset).chanlocs.labels};
        end
        
        %missing
        chans2cut = {};
        for missing = 1:sum(missing_chans)
            chans2cut_idx = find(~ismember(present_chans{full_chan(1)}, present_chans{missing_chans_locs(missing)}));
            chans2cut{missing} = present_chans{full_chan(1)}{chans2cut_idx}
        end
        chans2cut = unique(chans2cut);
        
        %cut 'em
        ALLEEG(full_chan) = pop_select(EEG, 'nochannel', chans2cut);
        
    end
    %could cause problems to do it this way...wanted it to be
    %length(clump), but now it'll be ok if ppl don't have every ttl
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG,'filename', myCurrentOutputFile, 'filepath', myOutputFolder);
end



