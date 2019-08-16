function Epoch_Rejecter(options, myCurrentInputFile, myCurrentOutputFile, Empty_data)

%--get file
EEG = pop_loadset('filename', myCurrentInputFile);

%--reject bad epochs
EEG = pop_eegthresh(EEG,1, [1:EEG.nbchan], options.uV_threshold * -1, options.uV_threshold, 0, 0.996, 0, 1);
EEG = eeg_checkset( EEG );
keyboard
if ~isempty(EEG.data)
    %--rereference
    EEG = pop_reref( EEG, [],'refloc',struct('labels',{'FCz'},'type',{''},'theta',{0},'radius',{0.12662},'X',{32.9279},'Y',{0},'Z',{78.363},'sph_theta',{0},'sph_phi',{67.208},'sph_radius',{85},'urchan',{31},'ref',{'FCz'},'datachan',{0}));
    
    %--save
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG,'filename', myCurrentOutputFile);
else
    fprintf(Empty_data, '\n%s cant be re-referenced because the data set is empty', myCurrentInputFile);
end

end