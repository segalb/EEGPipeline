function make_eeg_lab_data(options)

%--Individual
if strcmp(options.analysis_type, 'Dyad') ~= 1
    if ~isdir(options.myIndivFilesFolder) %gotta grab the individual files
        mkdir(options.myIndivFilesFolder)
    end
    addpath(options.myIndivFilesFolder);
    myCounter=0;
    for sub_idx=options.Indivs
        if ~ismember(sub_idx, options.exclusions)
            myCounter=myCounter+1;
            fprintf('\nMake EEGLAB data: Working on indiv file number: %d now\n\n', myCounter);
            %insert here which file the analysis will be performed on, and how it should be saved - follow study naming conventions.
            
            myCurrentInputFile =  strcat(num2str(sub_idx),'.vhdr');
            myCurrentFileName =   strcat(num2str(sub_idx), '_indiv');
            myCurrentOutputFile = strcat(num2str(sub_idx),'_indiv.set');
            
            if ~ismember(myCurrentInputFile, options.present_files)  %make sure file is there
                continue
            end
            
            fprintf('\nCurrent file is: %s \n\n', myCurrentInputFile);
            EEG = pop_loadbv(options.myRawFilesFolder, myCurrentInputFile);
            EEG.setname=['filename',myCurrentFileName];
            
            EEG = eeg_checkset( EEG );
            EEG = pop_resample( EEG, 250); %resample
            
            %get rid of ECG - but naming depends on subject
            if sub_idx < 2000
                try
                    EEG = pop_select( EEG,'channel',{'Fp1_1i' 'Fp2_1i' 'F7_1i' 'F3_1i' 'Fz_1i' 'F4_1i' 'F8_1i' 'FC5_1i' 'FC1_1i' 'FC2_1i' 'FC6_1i' 'T7_1i' 'C3_1i' 'Cz_1i' 'C4_1i' 'T8_1i' 'CP5_1i' 'CP1_1i' 'CP2_1i' 'CP6_1i' 'P7_1i' 'P3_1i' 'Pz_1i' 'P4_1i' 'P8_1i' 'PO9_1i' 'O1_1i' 'Oz_1i' 'O2_1i' 'PO10_1i'});
                catch
                    EEG = pop_select( EEG,'channel',{'Fp1_1' 'Fp2_1' 'F7_1' 'F3_1' 'Fz_1' 'F4_1' 'F8_1' 'FC5_1' 'FC1_1' 'FC2_1' 'FC6_1' 'T7_1' 'C3_1' 'Cz_1' 'C4_1' 'T8_1' 'CP5_1' 'CP1_1' 'CP2_1' 'CP6_1' 'P7_1' 'P3_1' 'Pz_1' 'P4_1' 'P8_1' 'PO9_1' 'O1_1' 'Oz_1' 'O2_1' 'PO10_1'});
                end
            elseif sub_idx > 2000
                try
                    EEG = pop_select( EEG,'channel',{'Fp1_2i' 'Fp2_2i' 'F7_2i' 'F3_2i' 'Fz_2i' 'F4_2i' 'F8_2i' 'FC5_2i' 'FC1_2i' 'FC2_2i' 'FC6_2i' 'T7_2i' 'C3_2i' 'Cz_2i' 'C4_2i' 'T8_2i' 'CP5_2i' 'CP1_2i' 'CP2_2i' 'CP6_2i' 'P7_2i' 'P3_2i' 'Pz_2i' 'P4_2i' 'P8_2i' 'PO9_2i' 'O1_2i' 'Oz_2i' 'O2_2i' 'PO10_2i'});
                catch
                    EEG = pop_select( EEG,'channel',{'Fp1_1' 'Fp2_1' 'F7_1' 'F3_1' 'Fz_1' 'F4_1' 'F8_1' 'FC5_1' 'FC1_1' 'FC2_1' 'FC6_1' 'T7_1' 'C3_1' 'Cz_1' 'C4_1' 'T8_1' 'CP5_1' 'CP1_1' 'CP2_1' 'CP6_1' 'P7_1' 'P3_1' 'Pz_1' 'P4_1' 'P8_1' 'PO9_1' 'O1_1' 'Oz_1' 'O2_1' 'PO10_1'});
                end
            end
                        
            % change channel names, look up channel locations, and add FCz back in.
            EEG=pop_chanedit(EEG, 'lookup', options.CapFolder,'changefield',{1 'labels' 'Fp1'},'changefield',{2 'labels' 'Fp2'},'changefield',{3 'labels' 'F7'},'changefield',{4 'labels' 'F3'},'changefield',{5 'labels' 'Fz'},'changefield',...
                {6 'labels' 'F4'},'changefield',{7 'labels' 'F8'},'changefield',{8 'labels' 'FC5'},'changefield',{9 'labels' 'FC1'},'changefield',{10 'labels' 'FC2'},'changefield',{11 'labels' 'FC6'},'changefield',{12 'labels' 'T7'},'changefield',...
                {13 'labels' 'C3'},'changefield',{14 'labels' 'Cz'},'changefield',{15 'labels' 'C4'},'changefield',{16 'labels' 'T8'},'changefield',{17 'labels' 'CP5'},'changefield',{18 'labels' 'CP1'},'changefield',{19 'labels' 'CP2'},'changefield',...
                {20 'labels' 'CP6'},'changefield',{21 'labels' 'P7'},'changefield',{22 'labels' 'P3'},'changefield',{23 'labels' 'Pz'},'changefield',{24 'labels' 'P4'},'changefield',{25 'labels' 'P8'},'changefield',{26 'labels' 'PO9'},'changefield',...
                {27 'labels' 'O1'},'changefield',{28 'labels' 'Oz'},'changefield',{29 'labels' 'O2'},'changefield',{30 'labels' 'PO10'},'append',30,'changefield',{31 'labels' 'FCz'},'lookup',options.CapFolder);
            %set reference to FCz
            EEG=pop_chanedit(EEG, 'changefield',{31 'datachan' 1},'changefield',{31 'datachan' 0},'setref',{'31' 'FCz'});
            
            EEG = eeg_checkset( EEG );
            EEG = pop_saveset( EEG,'filename',myCurrentOutputFile,'filepath', options.myIndivFilesFolder);
        end
    end
end

%--Dyad
if strcmp(options.analysis_type, 'Indiv') ~= 1
    if ~isdir(options.mySplitFilesFolder) %make place for split files if it doesn't already exist
        mkdir(options.mySplitFilesFolder)
    end
    addpath(options.mySplitFilesFolder);
    
    myCounter=0;
    for dyad_idx=options.Dyads
        if ~ismember(dyad_idx, options.exclusions)
            
            myCounter=myCounter+1;
            fprintf('\nMake EEGLAB data: Working on dyad file number: %d now\n\n', myCounter);
            %insert here which file the analysis will be performed on, and how it should be saved - follow study naming conventions.
            
            myCurrentInputFile =  strcat(num2str(dyad_idx),'.vhdr');
            myCurrentFileName =   strcat(num2str(dyad_idx),'_IS');
            sub_1 = num2str(dyad_idx + 1000);
            sub_2 = num2str(dyad_idx + 2000);
            myCurrentOutputFile_1 = strcat(sub_1, '_dyad.set');
            myCurrentOutputFile_2 = strcat(sub_2, '_dyad.set');
            
            if ~ismember(myCurrentInputFile, options.present_files)  %make sure file is there
                continue
            end
            
            fprintf('\nCurrent file is: %s \n\n', myCurrentInputFile);
            
            EEG = pop_loadbv(options.myRawFilesFolder, myCurrentInputFile);
            EEG.setname=['filename',myCurrentFileName];
            %shows datasets on GUI
            
            %cut extra channels from participant 2
            EEG = eeg_checkset( EEG );
            EEG = pop_resample( EEG, 250); %resample
            %select only one p
            EEG = pop_select( EEG,'channel',{'Fp1_1' 'Fp2_1' 'F7_1' 'F3_1' 'Fz_1' 'F4_1' 'F8_1' 'FC5_1' 'FC1_1' 'FC2_1' 'FC6_1' 'T7_1' 'C3_1' 'Cz_1' 'C4_1' 'T8_1' 'CP5_1' 'CP1_1' 'CP2_1' 'CP6_1' 'P7_1' 'P3_1' 'Pz_1' 'P4_1' 'P8_1' 'PO9_1' 'O1_1' 'Oz_1' 'O2_1' 'PO10_1'});
            
            % change channel names, look up channel locations, and add FCz back in.
            EEG=pop_chanedit(EEG, 'lookup', options.CapFolder,'changefield',{1 'labels' 'Fp1'},'changefield',{2 'labels' 'Fp2'},'changefield',{3 'labels' 'F7'},'changefield',{4 'labels' 'F3'},'changefield',{5 'labels' 'Fz'},'changefield',...
                {6 'labels' 'F4'},'changefield',{7 'labels' 'F8'},'changefield',{8 'labels' 'FC5'},'changefield',{9 'labels' 'FC1'},'changefield',{10 'labels' 'FC2'},'changefield',{11 'labels' 'FC6'},'changefield',{12 'labels' 'T7'},'changefield',...
                {13 'labels' 'C3'},'changefield',{14 'labels' 'Cz'},'changefield',{15 'labels' 'C4'},'changefield',{16 'labels' 'T8'},'changefield',{17 'labels' 'CP5'},'changefield',{18 'labels' 'CP1'},'changefield',{19 'labels' 'CP2'},'changefield',...
                {20 'labels' 'CP6'},'changefield',{21 'labels' 'P7'},'changefield',{22 'labels' 'P3'},'changefield',{23 'labels' 'Pz'},'changefield',{24 'labels' 'P4'},'changefield',{25 'labels' 'P8'},'changefield',{26 'labels' 'PO9'},'changefield',...
                {27 'labels' 'O1'},'changefield',{28 'labels' 'Oz'},'changefield',{29 'labels' 'O2'},'changefield',{30 'labels' 'PO10'},'append',30,'changefield',{31 'labels' 'FCz'},'lookup',options.CapFolder);
            %set reference to FCz
            EEG=pop_chanedit(EEG, 'changefield',{31 'datachan' 1},'changefield',{31 'datachan' 0},'setref',{'31' 'FCz'});
            %re-reference to average to bring FCz back in.
            
            %deal with hardcoded badchannels
            if ismember(str2double(sub_1), options.badchans_dyads.subs)
                sub_idx = find(options.badchans_dyads.subs == str2double(sub_1));
                badchan = cell(1, length(sub_idx));
                for chan = 1:length(sub_idx)
                    sidx = sub_idx(chan);
                    badchan{chan} = options.badchans_dyads.chans{sidx};
                end
                
                EEG = pop_select(EEG, 'nochannel', badchan);
            end
            
            EEG = eeg_checkset( EEG );
            EEG = pop_saveset( EEG,'filename', myCurrentOutputFile_1, 'filepath', options.mySplitFilesFolder);
              
            %repeat everything for participant 2
            EEG = pop_loadbv(options.myRawFilesFolder, myCurrentInputFile);
            EEG.setname=['filename',myCurrentFileName];
            
            %cut extra channels from participant 1
            EEG = eeg_checkset( EEG );
            EEG = pop_resample( EEG, 250); %resample
            EEG = pop_select( EEG,'channel',{'Fp1_2' 'Fp2_2' 'F7_2' 'F3_2' 'Fz_2' 'F4_2' 'F8_2' 'FC5_2' 'FC1_2' 'FC2_2' 'FC6_2' 'T7_2' 'C3_2' 'Cz_2' 'C4_2' 'T8_2' 'CP5_2' 'CP1_2' 'CP2_2' 'CP6_2' 'P7_2' 'P3_2' 'Pz_2' 'P4_2' 'P8_2' 'P09_2' 'O1_2' 'Oz_2' 'O2_2' 'PO10'});
            
            % change channel names, look up channel locations, and add FCz
            EEG=pop_chanedit(EEG, 'lookup',options.CapFolder,'changefield',{1 'labels' 'Fp1'},'changefield',...
                {2 'labels' 'Fp2'},'changefield',{3 'labels' 'F7'},'changefield',{4 'labels' 'F3'},'changefield',...
                {5 'labels' 'Fz'},'changefield',{6 'labels' 'F4'},'changefield',{7 'labels' 'F8'},'changefield',...
                {8 'labels' 'FC5'},'changefield',{9 'labels' 'FC1'},'changefield',{10 'labels' 'FC2'},'changefield',...
                {11 'labels' 'FC6'},'changefield',{12 'labels' 'T7'},'changefield',{13 'labels' 'C3'},'changefield',...
                {14 'labels' 'Cz'},'changefield',{15 'labels' 'C4'},'changefield',{16 'labels' 'T8'},'changefield',...
                {17 'labels' 'CP5'},'changefield',{18 'labels' 'CP1'},'changefield',{19 'labels' 'CP2'},'changefield',...
                {20 'labels' 'CP6'},'changefield',{21 'labels' 'P7'},'changefield',{22 'labels' 'P3'},'changefield',...
                {23 'labels' 'Pz'},'changefield',{24 'labels' 'P4'},'changefield',{25 'labels' 'P8'},'changefield',...
                {26 'labels' 'PO9'},'changefield',{27 'labels' 'O1'},'changefield',{28 'labels' 'Oz'},'changefield',...
                {29 'labels' 'O2'},'changefield',{30 'labels' 'PO10'},'append',30,'changefield',{31 'labels' 'FCz'},'lookup',options.CapFolder);
            %set reference to FCz
            EEG=pop_chanedit(EEG, 'changefield',{31 'datachan' 1},'changefield',{31 'datachan' 0},'setref',{'31' 'FCz'});
            %re-reference to average to bring FCz back in.
            
            %deal with hardcoded badchannels
            if ismember(str2double(sub_2), options.badchans_dyads.subs)
                sub_idx = find(options.badchans_dyads.subs == str2double(sub_2));
                badchan = cell(1, length(sub_idx));
                for chan = 1:length(sub_idx)
                    sidx = sub_idx(chan);
                    badchan{chan} = options.badchans_dyads.chans{sidx};
                end
                
                EEG = pop_select(EEG, 'nochannel', badchan);
            end
            
            EEG = eeg_checkset( EEG );
            EEG = pop_saveset( EEG,'filename',myCurrentOutputFile_2,'filepath', options.mySplitFilesFolder);
            
        end
    end
end