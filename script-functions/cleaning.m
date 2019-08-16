function filtering(options)

if ~isfolder(options.myCleanedFilesFolder) %make place for cleaned files if it doesn't already exist
    mkdir(options.myCleanedFilesFolder)
end
addpath(options.myCleanedFilesFolder);

if ~isfolder(options.EpochedPrecleaningFolder) 
    mkdir(options.EpochedPrecleaningFolder)
end
addpath(options.EpochedPrecleaningFolder);

%Rank_Deficiencies = fopen(fullfile(options.save_dir, 'Rank_Deficient_Segments.txt'), 'w');

%--get right TTLs
[subs, ttls] = Get_TTLs(options);

for sub_idx = 1:length(subs)
    curr_sub = subs{sub_idx};
    %curr_sub = round(curr_sub); %deal with .2s
    
    if ~ismember(curr_sub, options.exclusions)
        
        for ttl = 1:length(ttls)
            curr_ttl = ttls{ttl};
            
            if ismember(curr_ttl, options.BallSqueezeTTLs)
                
                fprintf('\nCleaning: Working on segment: %s now\n\n', curr_ttl);
                
                myCurrentInputFile = strcat(num2str(curr_sub), '_BallSqueezes.set'); %used to be cleaned
                myCurrentOutputFile = strcat(num2str(curr_sub), '_BallSqueezes_cleaned.set'); %used to be post-ica
                myCurrentFolder = fullfile(options.ClumpedTTlsFolder, 'BallSqueezes');
                myOutputFolder = fullfile(options.myCleanedFilesFolder, 'BallSqueezes_cleaned'); %used to be post-ica
                myPreDropFolder = fullfile(options.EpochedPrecleaningFolder, 'BallSqueezes_preclean');
                if ~isfolder(myOutputFolder), mkdir(myOutputFolder); end
                if ~isfolder(myPreDropFolder), mkdir(myPreDropFolder); end
                addpath(myOutputFolder)
                
                checkfile = fullfile(myOutputFolder, myCurrentOutputFile);
                
                if exist(checkfile, 'file') == 0 %so that it only runs once, since it's a clump
                    %note: this means you will have to delete the file if you
                    %want to write over it

                    %--clean
                    cleaner(options, myCurrentInputFile, myCurrentOutputFile, myCurrentFolder, myOutputFolder, myPreDropFolder);
                end
                
            elseif ismember(curr_ttl, options.HeartbeatTTLs)
                
                fprintf('\nCleaning: Working on segment: %s now\n\n', curr_ttl);
                
                myCurrentInputFile = strcat(num2str(curr_sub), '_Heartbeats.set');
                myCurrentOutputFile = strcat(num2str(curr_sub), '_Heartbeats_cleaned.set');
                myCurrentFolder = fullfile(options.ClumpedTTlsFolder, 'Heartbeats');
                myOutputFolder = fullfile(options.myCleanedFilesFolder, 'Heartbeats_cleaned');
                myPreDropFolder = fullfile(options.EpochedPrecleaningFolder, 'Heartbeats_preclean');
                if ~isfolder(myOutputFolder), mkdir(myOutputFolder); end
                if ~isfolder(myPreDropFolder), mkdir(myPreDropFolder); end
                addpath(myOutputFolder)
                
                checkfile = fullfile(myOutputFolder, myCurrentOutputFile);
                
                if exist(checkfile, 'file') == 0
                    %--clean
                    cleaner(options, myCurrentInputFile, myCurrentOutputFile, myCurrentFolder, myOutputFolder, myPreDropFolder);
                end
                
            elseif ismember(curr_ttl, options.IndivMuTTLs)
                
                fprintf('\nCleaning: Working on segment: %s now\n\n', curr_ttl);
                
                myCurrentInputFile = strcat(num2str(curr_sub), '_MuVideos.set');
                myCurrentOutputFile = strcat(num2str(curr_sub), 'MuVideos_cleaned.set');
                myCurrentFolder = fullfile(options.ClumpedTTlsFolder, 'MuVideos');
                myOutputFolder = fullfile(options.myCleanedFilesFolder, 'MuVideos_cleaned');
                myPreDropFolder = fullfile(options.EpochedPrecleaningFolder, 'MuVideos_preclean');
                if ~isfolder(myOutputFolder), mkdir(myOutputFolder); end
                if ~isfolder(myPreDropFolder), mkdir(myPreDropFolder); end
                addpath(myOutputFolder)
                
                checkfile = fullfile(myOutputFolder, myCurrentOutputFile);
                
                if exist(checkfile, 'file') == 0
                    %--clean
                    cleaner(options, myCurrentInputFile, myCurrentOutputFile, myCurrentFolder, myOutputFolder, myPreDropFolder);
                end
                
            elseif ismember(curr_ttl, options.BaselineTTLs)
                
                fprintf('\nCleaning: Working on segment: %s now\n\n', curr_ttl);
                
                myCurrentInputFile = strcat(num2str(curr_sub), '_BaselineTTLs.set');
                myCurrentOutputFile = strcat(num2str(curr_sub), '_BaselineTTLs_cleaned.set');
                myCurrentFolder = fullfile(options.ClumpedTTlsFolder, 'BaselineTTLs');
                myOutputFolder = fullfile(options.myCleanedFilesFolder, 'BaselineTTLs_cleaned');
                myPreDropFolder = fullfile(options.EpochedPrecleaningFolder, 'BaselineTTLs_preclean');
                if ~isfolder(myOutputFolder), mkdir(myOutputFolder); end
                if ~isfolder(myPreDropFolder), mkdir(myPreDropFolder); end
                addpath(myOutputFolder)
                
                checkfile = fullfile(myOutputFolder, myCurrentOutputFile);

                if exist(checkfile, 'file') == 0
                    %--clean
                    cleaner(options, myCurrentInputFile, myCurrentOutputFile, myCurrentFolder, myOutputFolder, myPreDropFolder);
                end
                
            else
                fprintf('\nCleaning: Working on segment: %s now\n\n', curr_ttl);
                
                myCurrentInputFile = strcat(num2str(curr_sub), curr_ttl, '.set');
                myCurrentOutputFile = strcat(num2str(curr_sub), curr_ttl, '_cleaned.set');
                myCurrentFolder = fullfile(options.mySegmentsFolder, strcat(extractAfter(curr_ttl, ':_'))); %formerly clean
                myOutputFolder = fullfile(options.myCleanedFilesFolder, strcat(extractAfter(curr_ttl, ':_'), '_cleaned'));
                myPreDropFolder = fullfile(options.EpochedPrecleaningFolder, strcat(extractAfter(curr_ttl, ':_'), '_preclean'));
                if ~isfolder(myOutputFolder), mkdir(myOutputFolder); end
                if ~isfolder(myPreDropFolder), mkdir(myPreDropFolder); end
                addpath(myOutputFolder)
                
                cleaner(options, myCurrentInputFile, myCurrentOutputFile, myCurrentFolder, myOutputFolder, myPreDropFolder);
            end
        end
    end
end






% %--Clean
% myCounter=0;
% for sub_idx = 1:length(subs)
%     curr_sub = subs{sub_idx};
%     for ttl = 1:length(ttls)
%         curr_ttl = ttls{ttl};
%
%         segment_folder = fullfile(options.mySegmentsFolder, extractAfter(curr_ttl, ':_'));
%         clean_segment_folder = fullfile(options.myCleanedFilesFolder, strcat(extractAfter(curr_ttl, ':_'), '_clean'));
%         if ~isfolder(clean_segment_folder)
%             mkdir(clean_segment_folder)
%         end
%         addpath(clean_segment_folder);
%
%         myCurrentInputFile = strcat(num2str(curr_sub), curr_ttl, '.set');
%         myCurrentOutputFile = strcat(num2str(curr_sub), curr_ttl, '.set');
%
%         %--clean
%         cleaner(segmentFolder, myCurrentInputFile, curr_ttl, options, myCurrentOutputFile, clean_segment_folder);
%
%     end
% end



