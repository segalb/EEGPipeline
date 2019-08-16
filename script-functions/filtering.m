function filtering(options)

if ~isfolder(options.myFilteredFilesFolder) %make place for cleaned files if it doesn't already exist
    mkdir(options.myFilteredFilesFolder)
end
addpath(options.myFilteredFilesFolder);

Weird_xmax_thing = fopen(fullfile(options.save_dir, 'Weird_xmax_files.txt'), 'w');

%--get right TTLs
[subs, ttls] = Get_TTLs(options);

for sub_idx = 1:length(subs)
    curr_sub = subs{sub_idx};
    
    if ~ismember(curr_sub, options.exclusions)
        
        for ttl = 1:length(ttls)
            curr_ttl = ttls{ttl};
            
            if ismember(curr_ttl, options.BallSqueezeTTLs)
                
                fprintf('\nFiltering: Working on segment: %s now\n\n', curr_ttl);
                
                myCurrentInputFile = strcat(num2str(curr_sub), '_BallSqueezes.set'); 
                myCurrentOutputFile = strcat(num2str(curr_sub), '_BallSqueezes_cleaned.set');
                myCurrentFolder = fullfile(options.ClumpedTTlsFolder, 'BallSqueezes');
                myOutputFolder = fullfile(options.myFilteredFilesFolder, 'BallSqueezes_cleaned');
                if ~isfolder(myOutputFolder), mkdir(myOutputFolder); end
                addpath(myOutputFolder)
                
                checkfile = fullfile(myOutputFolder, myCurrentOutputFile);
                
                if exist(checkfile, 'file') == 0 %so that it only runs once, since it's a clump
                    %note: this means you will have to delete the file if you
                    %want to write over it

                    %--clean
                    filterer(options, myCurrentInputFile, myCurrentOutputFile, myCurrentFolder, myOutputFolder, Weird_xmax_thing);
                end
                
            elseif ismember(curr_ttl, options.HeartbeatTTLs)
                
                fprintf('\nFiltering: Working on segment: %s now\n\n', curr_ttl);
                
                myCurrentInputFile = strcat(num2str(curr_sub), '_Heartbeats.set');
                myCurrentOutputFile = strcat(num2str(curr_sub), '_Heartbeats_cleaned.set');
                myCurrentFolder = fullfile(options.ClumpedTTlsFolder, 'Heartbeats');
                myOutputFolder = fullfile(options.myFilteredFilesFolder, 'Heartbeats_cleaned');
                if ~isfolder(myOutputFolder), mkdir(myOutputFolder); end
                addpath(myOutputFolder)
                
                checkfile = fullfile(myOutputFolder, myCurrentOutputFile);
                
                if exist(checkfile, 'file') == 0
                    %--clean
                    filterer(options, myCurrentInputFile, myCurrentOutputFile, myCurrentFolder, myOutputFolder, Weird_xmax_thing);
                end
                
            elseif ismember(curr_ttl, options.IndivMuTTLs)
                
                fprintf('\nFiltering: Working on segment: %s now\n\n', curr_ttl);
                
                myCurrentInputFile = strcat(num2str(curr_sub), '_MuVideos.set');
                myCurrentOutputFile = strcat(num2str(curr_sub), '_MuVideos_cleaned.set');
                myCurrentFolder = fullfile(options.ClumpedTTlsFolder, 'MuVideos');
                myOutputFolder = fullfile(options.myFilteredFilesFolder, 'MuVideos_cleaned');
                if ~isfolder(myOutputFolder), mkdir(myOutputFolder); end
                addpath(myOutputFolder)
                
                checkfile = fullfile(myOutputFolder, myCurrentOutputFile);
                
                if exist(checkfile, 'file') == 0
                    %--clean
                    filterer(options, myCurrentInputFile, myCurrentOutputFile, myCurrentFolder, myOutputFolder, Weird_xmax_thing);
                end
                
            else
                fprintf('\nFiltering: Working on segment: %s now\n\n', curr_ttl);
                
                myCurrentInputFile = strcat(num2str(curr_sub), curr_ttl, '.set');
                myCurrentOutputFile = strcat(num2str(curr_sub), curr_ttl, '_cleaned.set');
                myCurrentFolder = fullfile(options.mySegmentsFolder, strcat(extractAfter(curr_ttl, '!_'))); %formerly clean
                myOutputFolder = fullfile(options.myFilteredFilesFolder, strcat(extractAfter(curr_ttl, '!_'), '_cleaned'));
                if ~isfolder(myOutputFolder), mkdir(myOutputFolder); end
                addpath(myOutputFolder)
                
                filterer(options, myCurrentInputFile, myCurrentOutputFile, myCurrentFolder, myOutputFolder, Weird_xmax_thing);
            end
        end
    end
end

fclose(Weird_xmax_thing);

end





