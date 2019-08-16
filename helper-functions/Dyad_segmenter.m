function Dyad_segmenter(dyad_ttls, dyad_idx, p, missing_TTLs, options)

myCurrentInputFile = strcat(num2str(p*1000 + dyad_idx),'_dyad.set');
fprintf('\nCurrent file is: %s \n\n', myCurrentInputFile);
sub_idx = p*1000 + dyad_idx;

full_EEG = pop_loadset('filename',myCurrentInputFile,'filepath',options.mySplitFilesFolder);
full_EEG.setname = [myCurrentInputFile];
data_ttls = struct2cell(full_EEG.event); %this is really stupid

myCounter = 0;
for ttl_idx = 1:numel(dyad_ttls.names)
    
    myCounter=myCounter+1;
    fprintf('\nSegmentation: Working on file number: %d now\n\n', myCounter);
    
    seg_name = strcat(num2str(p*1000 + dyad_idx), options.dyad_ttls.names{ttl_idx});
    ttl = options.dyad_ttls.markers{ttl_idx};
    seg_start = options.dyad_ttls.starts(ttl_idx);
    seg_end = options.dyad_ttls.ends(ttl_idx);

    %check that TTL exists in data
    finder = find(strcmp(data_ttls, ttl));
    if ~isempty(finder) % only run if ttl exists
        
        %make special folder for each TTL
        segment_folder = fullfile(options.mySegmentsFolder, extractAfter(options.dyad_ttls.names{ttl_idx}, ":_"));
        if ~isdir(segment_folder)
            mkdir(segment_folder)
        end
        addpath(segment_folder);
        
        %deal with the .# weirdness. will only work for one, but should only
        %be one ttl of a kind in each
        tester = num2str(sub_idx);
        if length(tester) > 5
            seg_name = strcat(seg_name(1:4), seg_name(7:end) );
        end
        
        if sum(sum(strcmp(data_ttls, ttl))) == 1
            %segment
            EEG = eeg_checkset( full_EEG );
            EEG = pop_epoch( EEG, {  ttl  }, [seg_start  seg_end], 'newname', seg_name, 'epochinfo', 'yes');
            %save file
            EEG = pop_saveset( EEG, 'filename', seg_name,'filepath', segment_folder);
            
        elseif sum(sum(strcmp(data_ttls, ttl))) == 2  %%%THINK ABOUT MORE THAN 2
            
            if strcmp(ttl, 'S  1')
                
                EEG = eeg_checkset( full_EEG );
                EEG = pop_epoch( EEG, {  ttl  }, [seg_start  seg_end], 'newname', seg_name, 'epochinfo', 'yes');
                %drop second because it's always the second
                EEG.data = EEG.data(:, :, 1);
                EEG.epoch = EEG.epoch(:, 1);
                EEG = pop_saveset( EEG,'filename', seg_name,'filepath', segment_folder);
                
            elseif strcmp(ttl, 'S  3')
                
                ttl_names = squeeze(data_ttls(6, :, :));
                %so ttl_names will have multiple S3s
                %we want the one that comes after S2
                two_idx = find(strcmp(ttl_names, 'S  2'));
                three_idx = find(strcmp(ttl_names, 'S  3'));
                four_idx = find(strcmp(ttl_names, 'S  4')); %cuz 134 sucks
                idx = [];
                for instance = 1:length(three_idx)
                    if three_idx(instance) == two_idx + 1 %find the 3 after 2
                        idx = instance;
                    elseif three_idx(instance) == four_idx - 1 %find the three before 4
                        idx = instance;
                    end
                end
                
                EEG = eeg_checkset( full_EEG );
                EEG = pop_epoch( EEG, {  ttl  }, [seg_start  seg_end], 'newname', seg_name, 'epochinfo', 'yes');
                %take the one identified above
                EEG.data = EEG.data(:, :, idx);
                EEG.epoch = EEG.epoch(:, idx);
                EEG = pop_saveset( EEG,'filename', seg_name,'filepath', segment_folder);
                
            elseif strcmp(ttl, 'S  7')
                
                ttl_names = squeeze(data_ttls(6, :, :));
                %so ttl_names will have multiple S3s
                %we want the one that comes after S2
                six_idx = find(strcmp(ttl_names, 'S  6'));
                seven_idx = find(strcmp(ttl_names, 'S  7'));
                idx = [];
                for instance = 1:length(seven_idx)
                    if seven_idx(instance) == six_idx + 1
                        idx = instance;
                    end
                end
                
                EEG = eeg_checkset( full_EEG );
                EEG = pop_epoch( EEG, {  ttl  }, [seg_start  seg_end], 'newname', seg_name, 'epochinfo', 'yes');
                %take the one identified above
                EEG.data = EEG.data(:, :, idx);
                EEG.epoch = EEG.epoch(:, idx);
                EEG = pop_saveset( EEG,'filename', seg_name,'filepath', segment_folder);
                
            else
                %split up the multiple TTLs (which someone will have to
                %deal with =/
                duplicates = sum(sum(strcmp(data_ttls, ttl)));
                fprintf(missing_TTLs, '\nSub %.1f has extra TTLs (dyad data):', sub_idx);
                fprintf(missing_TTLs, '\n %.0f of marker %s, which is %s \n', duplicates, ttl, seg_name);
                %again, this is undoubtedly asinine
                ttls = char();
                for ttl_idx = 1:size(full_EEG.event, 2)
                    ttls = char(ttls, full_EEG.event(ttl_idx).type);
                end
                ttls = ttls(2:end, :); %ugh, get rid of empty first cell
                doubled_ttl = find(contains(string(ttls), ttl)); %find both instances!
                EEG1 = full_EEG; %possible there will be more than two but let's cross that bridge when we get there
                EEG2 = full_EEG;
                EEG1.event(doubled_ttl(2)).type = ''; %get rid of one so we can focus on the other
                EEG2.event(doubled_ttl(1)).type = '';
                if strcmp(ttl, 'S200') ~= 1 %action coordination only needs first
                    %do first appearance
                    EEG = eeg_checkset( EEG1 );
                    EEG = pop_epoch( EEG, {  ttl  }, [seg_start  seg_end], 'newname', strcat(seg_name, '_firstTTL'), 'epochinfo', 'yes');
                    %save file
                    EEG = pop_saveset( EEG,'filename', seg_name,'filepath', segment_folder);
                    %do second appearance
                    EEG = eeg_checkset( EEG2 );
                    EEG = pop_epoch( EEG, {  ttl  }, [seg_start  seg_end], 'newname', strcat(seg_name, '_secondTTL'), 'epochinfo', 'yes');
                    %save file
                    EEG = pop_saveset( EEG,'filename', seg_name,'filepath', segment_folder);
                elseif strcmp(ttl, 'S200') == 1
                    %only second appearance
                    EEG = eeg_checkset( EEG2 );
                    EEG = pop_epoch( EEG, {  ttl  }, [seg_start  seg_end], 'newname', seg_name, 'epochinfo', 'yes');
                    %save file
                    EEG = pop_saveset( EEG,'filename', seg_name,'filepath', segment_folder);
                end
            end
        else
            duplicates = sum(sum(strcmp(data_ttls, ttl)));
            fprintf(missing_TTLs, '\nSub %.1f has extra TTLs (dyad data):', sub_idx);
            fprintf(missing_TTLs, '\n %.0f of marker %s, which is %s \n', duplicates, ttl, seg_name);
            fprintf(missing_TTLs, 'this code does not yet deal with that number of duplicates, sorry');
            
        end
    elseif strcmp(ttl, 'S200') == 1
        if sum(sum(strcmp(data_ttls, 'S201'))) == 1 %check for ttl 201 (end of action coord)
            EEG = eeg_checkset( full_EEG );
            EEG = pop_epoch( EEG, {  'S201'  }, [-240  0], 'newname', seg_name, 'epochinfo', 'yes');
            %save file
            EEG = pop_saveset( EEG,'filename', seg_name,'filepath', segment_folder);
            fprintf(missing_TTLs, '\nSub %.1f is missing (dyad data):', sub_idx);
            fprintf(missing_TTLs,  '\n TTL %s, using S201 instead for %s \n', ttl, seg_name);
        else
            fprintf(missing_TTLs, '\nSub %.1f is missing (dyad data):', sub_idx);
            fprintf(missing_TTLs,  '\n %s \n', seg_name);
        end
    else
        fprintf(missing_TTLs, '\nSub %.1f is missing:', sub_idx);
        fprintf(missing_TTLs,  '\n %s \n', seg_name);
    end
    
end


end

