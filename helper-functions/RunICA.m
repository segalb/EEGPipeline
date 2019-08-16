function RunICA(options, myCurrentInputFile, myCurrentOutputFile, myOutputFolder, curr_file, insufficient)

if exist(myCurrentInputFile, 'file')
    if ~isdir(myOutputFolder)
        mkdir(myOutputFolder)
    end

    %--get file
    EEG = pop_loadset('filename', myCurrentInputFile); %, 'filepath', myCurrentFolder);
    fprintf('\nICA: Working on %s now\n\n', EEG.filename);

    if EEG.pnts * EEG.trials > (30 * length(EEG.chanlocs)^2) %need sufficient length of data for ICA
        %--run ICA
        EEG = pop_runica(EEG, 'icatype', options.icatype);
        
        %--ICLabel
        EEG.data = double(EEG.data); %I don't know why these save as single precision
        EEG.icaact = double(EEG.icaact); %but they have to be double
        rng('default') %this keeps changing too; no clue why (rng = random number generator)
        EEG = iclabel(EEG);
        
        %--save ICA weights (thanks Eric!)
        pop_expica(EEG, 'weights', fullfile(myOutputFolder, [myCurrentOutputFile '_ICAw.txt']));
        
        %--save
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG,'filename', myCurrentOutputFile, 'filepath', myOutputFolder);
    else
        fprintf(insufficient, '\n\n%s has insufficient data points for running ICA', curr_file);
    end
    
end

end

