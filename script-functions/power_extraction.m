function power_extraction(options)

if ~isdir(options.power_folder) %make place for post-blink files if it doesn't already exist
    mkdir(options.power_folder)
end
addpath(options.power_folder);

switch options.ICA_power
    case 'on'
        output_folder = fullfile(options.power_folder, 'ICA_power');
    case 'off'
        output_folder = fullfile(options.power_folder, options.decomp);
end

if ~isdir(output_folder) %make place for post-blink files if it doesn't already exist
    mkdir(output_folder)
end
addpath(output_folder);

cd(options.FinalSegments)
segments = dir('*');
segments = {segments.name};

%--get ttls
if strcmp(options.analysis_type, 'Indiv')
    ttls = options.indiv_ttls.names;
elseif strcmp(options.analysis_type, 'Dyad')
    ttls = options.dyad_ttls.names;
else
    ttls = [options.dyad_ttls.names options.indiv_ttls.names];
end

%--loop through each folder
for folder_idx = 1:numel(segments)
    
    curr_segment = segments{folder_idx};
    
    %only run if we're asking for this ttl!
    if ~ismember(curr_segment, ttls)
        continue
    end
    
    curr_segment_folder = fullfile(options.FinalSegments, curr_segment);
    
    fprintf('\nPower extraction: Working on segment %s now\n\n', curr_segment);
    
    cd(curr_segment_folder)
    ps_segs = dir('*.set');
    ps_segs = {ps_segs.name};
    
    p_names = regexp(ps_segs, ':', 'split');
    ps = cell(1, length(p_names));
    for idx = 1:length(p_names)
        p_temp = p_names{idx};
        ps{idx} = p_temp{1};
    end
    
    %--pre-allocate output table
    switch options.ICA_power
        case 'on'
            power_table = cell2table(cell(0, 2), 'VariableNames', {'subject' strcat(options.ica_electrode_flag, '_power')});
            topo_table = [];
        case 'off'
            power_table = cell2table(cell(0, numel(options.electrode_template) + 1), 'VariableNames', ['subject' options.electrode_template]);
        otherwise
            error('Have to use either ICA or decomposition to get power.')
    end
    
    %--loop through each file in the folder
    for file_idx = 1:numel(ps_segs)
        
        curr_file = ps_segs{file_idx};
        curr_p = ps{file_idx};
        
        fprintf('\nPower extraction: Working on file %s now\n\n', curr_file);
        
        %--load data
        EEG = pop_loadset('filename', curr_file);
        
        %--laplacian filter
        switch options.laplacian
            case 'on'
                X = [EEG.chanlocs.X];
                Y = [EEG.chanlocs.Y];
                Z = [EEG.chanlocs.Z];
                EEG.data = laplacian_perrinX(EEG.data,X,Y,Z); %code from Brandon
            otherwise
        end
        
        switch options.ICA_power
            
            case 'on'
                
                [mu_power, topo_vals]= Mu_Component_Extraction(EEG, options, curr_segment, curr_p, output_folder);
                new_power = [str2double(curr_p) mu_power];
                power_table = [power_table; array2table(new_power, 'VariableNames', {'subject' strcat(options.ica_electrode_flag, '_power')})];
                
                %for mapping components
                if ~isempty(topo_vals)
                    topo_vals = [str2double(curr_p) topo_vals];
                    topo_table = [topo_table; topo_vals];
                end
                
            case 'off'
                
                %--spectral decompositionå
                switch options.decomp
                    case 'wavelet' %code from Brandon
                        
                        mu_power = brandon_wavelet(EEG, options);
                        mu_power = mu_power'; %need this orientation
                        
                    case 'Spectopo' %this is from EEGLAB, uses pwelch(), not FFT
                        
                        [power, freq] = spectopo(EEG.data, 0, EEG.srate, 'plot', 'off');
                        %freq is just 0-125 Hz. power is power at each electrode x freq
                        
                        mu_power = power(:, freq <= options.pfreq_high & freq >= options.pfreq_low);
                        mu_power = mean(mu_power, 2);
                        mu_power = mu_power';
                        
                    otherwise
                        error('choose one of the two decomposition options')
                        
                end
                
                %--deal with missing channels
                if length(mu_power) < length(options.electrode_template)
                    missing_idx = ismember(options.electrode_template, {EEG.chanlocs.labels});
                    counter = 0;
                    new_power = NaN(1, length(options.electrode_template));
                    for v = 1:length(missing_idx)
                        if missing_idx(v) == 1
                            counter = counter + 1;
                            new_power(v) = mu_power(counter);
                        end
                    end
                    
                    new_power = [str2double(curr_p) new_power];
                    
                elseif length(mu_power) == length(options.electrode_template)
                    
                    new_power = [str2double(curr_p) mu_power];
                    
                end
                
                %--add to output file
                power_table = [power_table; array2table(new_power, 'VariableNames', ['subject' options.electrode_template])];
                
            otherwise
                error('Have to use either ICA or decomposition to get power.')
        end
    end
    
    %--save
    %.mat
    fn = fullfile(output_folder, strcat(curr_segment, '_POWER'));
    save(strcat(fn, '.mat'), 'power_table')
    
    if exist('topo_table', 'var')
        topo_fn = fullfile(output_folder, strcat(curr_segment, '_Mu_Components'));
        save(strcat(topo_fn, '.mat'), 'topo_table')
    end
    
    %.csv
    writetable(power_table, strcat(fn, '.csv'))
    
end

end