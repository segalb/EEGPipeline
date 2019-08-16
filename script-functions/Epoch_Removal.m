function Epoch_Removal(options)

if ~isdir(options.FinalSegments) %make place for final files if it doesn't already exist
    mkdir(options.FinalSegments)
end
addpath(options.FinalSegments);

Empty_data = fopen(fullfile(options.save_dir, 'Empty_Data_for_Epoch_removal.txt'), 'w');

%--get ttls
if strcmp(options.analysis_type, 'Indiv')
    ttls = options.indiv_ttls.names;
elseif strcmp(options.analysis_type, 'Dyad')
    ttls = options.dyad_ttls.names;
else
    ttls = [options.dyad_ttls.names options.indiv_ttls.names];
end

for seg_idx = 1:numel(ttls)
    
    curr_seg = ttls{seg_idx};
    
    %--make output folder (goes before to avoid "post blinks"
    myOutputFolder = fullfile(options.FinalSegments, curr_seg);
    if ~isdir(myOutputFolder)
        mkdir(myOutputFolder)
    end
    
    %--deal with two separate sources
    if ismember(curr_seg, options.allclumpTTLs)
        
        current_folder = options.DeclumpedFiles;
        
    elseif ~ismember(curr_seg, options.allclumpTTLs)
        
        current_folder = options.PostBlinkFolder;
        %annoying nomenclature differences:
        curr_seg = strcat(curr_seg(3:end), '__Post_Blinks');
        
    end
    
    curr_segment_folder = fullfile(current_folder, curr_seg);
    
    %--get files
    if exist(curr_segment_folder, 'dir')
        cd(curr_segment_folder)
    else
        continue %don't do anything if the file doesn't exist
    end
    ps_segs = dir('*.set');
    ps_segs = {ps_segs.name};
    
    fprintf('\nEpoch Removal: Working on segment %s now\n\n', curr_seg);
    
    %--loop through each file in the folder
    for file_idx = 1:numel(ps_segs)
        
        fn = ps_segs{file_idx};
        
        myCurrentInputFile = fullfile(curr_segment_folder, fn);
        
        if ~ismember(curr_seg, options.allclumpTTLs)
            
            fn = strsplit(fn, '_Post');
            fn = fn{1};
            fn = strcat(fn, '.set');
            myCurrentOutputFile = fullfile(myOutputFolder, fn);
        end
        
        myCurrentOutputFile = fullfile(myOutputFolder, fn);
        
        if ~exist(myCurrentOutputFile, 'file')  %don't write over

            %--Reject bad epochs
            Epoch_Rejecter(options, myCurrentInputFile, myCurrentOutputFile, Empty_data)
            
        else
            continue
        end
    end
end
fclose(Empty_data);
end