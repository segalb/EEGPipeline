function Indiv_segmenter(sub_idx, missing_TTLs, options, indiv_ttls)

myCurrentInputFile = strcat(num2str(sub_idx), '_indiv.set');
fprintf('\nCurrent file is: %s \n\n', myCurrentInputFile);

%get file
full_EEG = pop_loadset('filename',myCurrentInputFile,'filepath',options.myIndivFilesFolder);
full_EEG.setname=[myCurrentInputFile];

data_ttls = struct2cell(full_EEG.event); %this is really stupid

myCounter = 0;
for ttl_idx = 1:numel(indiv_ttls.names)
    
    myCounter=myCounter+1;
    fprintf('\nSegmentation: Working on file number: %d now\n\n', myCounter);
    
    %make special folder for each TTL
    segment_folder = fullfile(options.mySegmentsFolder, extractAfter(options.indiv_ttls.names{ttl_idx}, ":_"));
    if ~isdir(segment_folder)
        mkdir(segment_folder)
    end
    addpath(segment_folder);
    
    seg_name = strcat(num2str(sub_idx), options.indiv_ttls.names{ttl_idx});
    ttl = options.indiv_ttls.markers{ttl_idx};
    seg_start = options.indiv_ttls.starts(ttl_idx);
    seg_end = options.indiv_ttls.ends(ttl_idx);
    
    %check that TTL exists in data
    finder = find(strcmp(data_ttls, ttl));
    if ~isempty(finder)  % only run if ttl exists
        if sum(sum(strcmp(data_ttls, ttl))) == 1
            %segment
            EEG = eeg_checkset( full_EEG );
            EEG = pop_epoch( EEG, {  ttl  }, [seg_start  seg_end], 'newname', seg_name, 'epochinfo', 'yes');
            %save file
            EEG = pop_saveset( EEG,'filename', EEG.setname,'filepath', segment_folder);
        elseif sum(sum(strcmp(data_ttls, ttl))) == 2
            %split up the multiple TTLs (which someone will have to
            %deal with =/
            duplicates = sum(sum(strcmp(data_ttls, ttl)));
            fprintf(missing_TTLs, '\nSub %.1f has extra TTLs:', sub_idx);
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
                EEG = pop_saveset( EEG,'filename', EEG.setname,'filepath', segment_folder);
                %do second appearance
                EEG = eeg_checkset( EEG2 );
                EEG = pop_epoch( EEG, {  ttl  }, [seg_start  seg_end], 'newname', strcat(seg_name, '_secondTTL'), 'epochinfo', 'yes');
                %save file
                EEG = pop_saveset( EEG,'filename', EEG.setname,'filepath', segment_folder);
            elseif strcmp(ttl, 'S200') == 1
                %only second appearance
                EEG = eeg_checkset( EEG2 );
                EEG = pop_epoch( EEG, {  ttl  }, [seg_start  seg_end], 'newname', seg_name, 'epochinfo', 'yes');
                %save file
                EEG = pop_saveset( EEG,'filename', EEG.setname,'filepath', segment_folder);
            end
        else
            duplicates = sum(sum(strcmp(data_ttls, ttl)));
            fprintf(missing_TTLs, '\nSub %.1f has extra TTLs:', sub_idx);
            fprintf(missing_TTLs, '\n %.0f of marker %s, which is %s \n', duplicates, ttl, seg_name);
            fprintf(missing_TTLs, 'this code does not yet deal with that number of duplicates, sorry');
            
        end
    elseif strcmp(ttl, 'S200') == 1
        if sum(sum(strcmp(data_ttls, 'S201'))) == 1 %check for ttl 201 (end of action coord)
            EEG = eeg_checkset( full_EEG );
            EEG = pop_epoch( EEG, {  'S201'  }, [-240  0], 'newname', seg_name, 'epochinfo', 'yes');
            %save file
            EEG = pop_saveset( EEG,'filename', EEG.setname,'filepath', segment_folder);
            fprintf(missing_TTLs, '\nSub %.1f is missing:', sub_idx);
            fprintf(missing_TTLs,  '\n TTL %s, using S201 instead for %s \n', ttl, seg_name);
        else
            fprintf(missing_TTLs, '\nSub %.1f is missing:', sub_idx);
            fprintf(missing_TTLs,  '\n %s \n', seg_name);
        end
    else
        fprintf(missing_TTLs, '\nSub %.1f is missing:', sub_idx);
        fprintf(missing_TTLs,  '\n %s \n', seg_name);
    end
    
end

end

