function Remove_Artifacts(options, myCurrentInputFile, myCurrentOutputFile, myOutputFolder, components_log)

if exist(myCurrentInputFile, 'file')
    if ~isdir(myOutputFolder)
        mkdir(myOutputFolder)
    end
    
    %--get file
    EEG = pop_loadset('filename', myCurrentInputFile);
    fprintf('\nArtifact Removal: Working on %s now\n\n', EEG.filename);
    
    %--get plurality eye components
    eye_comps_idx = [];
    %--get plurality muscle components
    emg_comps_idx = [];
    %--get plurality artifact components
    other_comps_idx = [];
    for comp_idx = 1:size(EEG.etc.ic_classification.ICLabel.classifications, 1)
        plur_idx = find(EEG.etc.ic_classification.ICLabel.classifications(comp_idx,:) > options.blink_threshold);
        if plur_idx == 3 %3 is eye
            eye_comps_idx = [eye_comps_idx comp_idx];
        end
        if plur_idx == 2 %2 is muscle
            emg_comps_idx = [emg_comps_idx comp_idx];
        end
        if plur_idx == 7 %7 is "other"
            other_comps_idx = [other_comps_idx comp_idx];
        end
    end
    
    artifacts_comps_idx = eye_comps_idx;
    if options.emg_removal == 'on'
        artifacts_comps_idx = [artifacts_comps_idx emg_comps_idx];
    end
    if options.other_removal == 'on'
        artifacts_comps_idx = [artifacts_comps_idx other_comps_idx];
    end
    
    %--save component image for checking
    switch options.save_img
        case 'on'
            
            artifact_component_image_folder = fullfile(myOutputFolder, 'Artifact_component_images');
            if ~isdir(artifact_component_image_folder), mkdir(artifact_component_image_folder);end
            
            if numel(artifacts_comps_idx) > 0
                curr_file = strsplit(myCurrentInputFile, '/');
                curr_file = curr_file{numel(curr_file)};
                for comp_idx = artifacts_comps_idx
                    pop_prop_extended(EEG, 0, comp_idx);
                    fn = strcat(curr_file, "_component_", num2str(comp_idx), '.png');
                    saveas(gcf, fullfile(artifact_component_image_folder, fn));
                    close all
                end
            end
        otherwise
    end
    
    %--remove blink component(s)
    EEG = pop_subcomp( EEG, [artifacts_comps_idx], 0);
    EEG = eeg_checkset( EEG );
    
    %--update ic labels
    EEG = pop_runica(EEG, 'icatype', options.icatype); %just in case
    EEG = iclabel(EEG);
    
    %--document
    nremoved = length(artifacts_comps_idx);
    fprintf(components_log, '\n\n%s had %g components removed for being artifacts', myCurrentInputFile, nremoved);
    
    %--save
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG,'filename', myCurrentOutputFile, 'filepath', myOutputFolder);
    
end

end