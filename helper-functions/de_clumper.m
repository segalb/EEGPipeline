function de_clumper(options, myCurrentInputFile, seg_start, ttls, seg_ends, seg_names, curr_sub)

%--get file
EEG = pop_loadset('filename', myCurrentInputFile);

%--find ttl
EEG = eeg_checkset( EEG );
%get events
events = struct2cell(EEG.event);
%get ttls
types = squeeze(events(6, :, :));

if ~(size(events, 1) < 9) % won't have epoch field if only one seg survives
    
    %get the epoch they occur in
    epochs = squeeze(events(9, :, :));

    for ttl_idx = 1:numel(ttls)
        
        ttl = ttls{ttl_idx};
        seg_end = seg_ends(ttl_idx);
        seg_name = seg_names{ttl_idx};
        
        fprintf('\nDe-clumping: Working on %s%s\n\n', EEG.filename, seg_name);
        
        %find where ttls occur
        ttl_struct_idx = find(strcmp(ttl, types));
        
        if ~isempty(ttl_struct_idx) %only do this if the ttl exists!
            
            %deal with stopping since there are missing epochs
            data_idx = epochs{ttl_struct_idx};
            
            if ttl_idx ~= numel(ttls) %all but the last ttl
                %find where next ttl starts
                next_ttl = ttl_idx + 1;
                next_ttl = ttls{next_ttl};
                next_ttl_struct_idx = find(strcmp(next_ttl, types));
                if length(next_ttl_struct_idx) > 1
                    next_ttl_struct_idx = next_ttl_struct_idx(1);
                end
                
                %ensure that you don't take anything from the next segment
                if ~isempty(next_ttl_struct_idx) %possible that the next ttl is missing, which can cause problems
                    
                    last_epoch = min(epochs{next_ttl_struct_idx}, data_idx + (seg_end - seg_start) - 1);
                    
                elseif isempty(next_ttl_struct_idx)
                    
                    last_epoch = min(size(EEG.data, 3), data_idx + (seg_end - seg_start) - 1); %can't go past end
                end
                
            elseif ttl_idx == numel(ttls) %last ttl - find end
                
                last_epoch = min(size(EEG.data, 3), data_idx + (seg_end - seg_start) - 1); %can't go past end
                
            end
            
            %--segment
            segment = EEG;
            segment.data = segment.data(:, :, data_idx:last_epoch);
            
            %--fix EEG structure
            %trials
            segment.trials = length(data_idx:last_epoch);
            %events
            seg_events = events(:, :, data_idx:last_epoch);
            segment.event = cell2struct(seg_events, fieldnames(segment.event), 1);
            %epochs
            all_epochs = struct2cell(segment.epoch);
            all_epochs = all_epochs(:, :, data_idx:last_epoch);
            segment.epoch = cell2struct(all_epochs, fieldnames(segment.epoch), 1);
            
            %--set up names
            segment_folder = fullfile(options.DeclumpedFiles, seg_name);
            if ~isdir(segment_folder)
                mkdir(segment_folder)
            end
            seg_name = strcat(curr_sub, seg_name);
            
            %save file
            segment = pop_saveset( segment ,'filename', seg_name,'filepath', segment_folder);
            
        else
            continue
        end
  
            
    end
    
end

end