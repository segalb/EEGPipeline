function filterer(options, myCurrentInputFile, myCurrentOutputFile, myCurrentFolder, myOutputFolder, Weird_xmax_thing)

if exist(fullfile(myCurrentFolder, myCurrentInputFile))
    
    %moved this down so that it wouldn't have to print for missing
    fprintf('\nFilterer: Current file is: %s \n\n', myCurrentInputFile);
    
    %--get file
    EEG = pop_loadset('filename', myCurrentInputFile,'filepath', myCurrentFolder);
    
    %--filter
    EEG = pop_eegfiltnew(EEG, options.lowpass, options.highpass, [],0);

    %--epoch
    if EEG.xmax < 1 %causes a break for one participant...
        fprintf(Weird_xmax_thing, '\n%s needed its EEG.xmax changed to 1 because it was %f, which is too small for epoching', myCurrentInputFile, EEG.xmax);
        EEG.xmax = 1;
    end
    EEG = eeg_regepochs(EEG, 'recurrence', 1);
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset( EEG,'filename', myCurrentOutputFile, 'filepath', myOutputFolder);
    %bad epochs removed in Epoch_Removal to ensure enough data for ICA
    
end

end