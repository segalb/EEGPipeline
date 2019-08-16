function [overall_meanPower, topo_vals] = Mu_Component_Extraction(EEG, options, curr_segment, curr_p, output_folder)

%--get plurality brain components
brain_comps_idx = [];
for comp_idx = 1:size(EEG.etc.ic_classification.ICLabel.classifications, 1)
    plur_idx = find(EEG.etc.ic_classification.ICLabel.classifications(comp_idx,:) > options.brain_threshold); %== plurality);
    if plur_idx == 1
        brain_comps_idx = [brain_comps_idx comp_idx];
    end
end
brain_comps = EEG.etc.ic_classification.ICLabel.classifications(brain_comps_idx, :);

%now find the ones that are in the right place
electrodes_to_use = find(ismember({EEG.chanlocs.labels}, options.ica_electrodes));
mu_comps = [];
for comp_idx = brain_comps_idx
    high = max(EEG.icawinv(:, comp_idx));
    low = min(EEG.icawinv(:, comp_idx));
    high_idx = find(EEG.icawinv(:, comp_idx) == high);
    low_idx = find(EEG.icawinv(:, comp_idx) == low);
    
    if ismember(high_idx, electrodes_to_use) || ismember(low_idx, electrodes_to_use)
        mu_comps = [mu_comps comp_idx];
    end
    
end

%--Spectral decomposition
% from https://www.researchgate.net/post/How_can_I_get_and_extract_a_mean_of_PSD_in_EEGlab
[comppower, compfreq] = spectopo(EEG.icaact, 0, EEG.srate, 'plot', 'off'); %get power and frequency from components

if ~isempty(mu_comps) %some participants don't have components that fit the criteria
    meanPower = zeros(1, numel(mu_comps)); %pre-allocate
    for c_idx = 1:numel(mu_comps)
        comp_mean = mean(comppower(mu_comps(c_idx), (compfreq >= options.pfreq_low & compfreq <= options.pfreq_high))); %this  is just power for that component (averaged)
        meanPower(c_idx) = comp_mean;
    end
    overall_meanPower = mean(meanPower); %super dumb, but it'll work (this is because some people have multiple components)
elseif isempty(mu_comps)
    overall_meanPower = NaN;
end

%--Print images
switch options.save_img
    case 'on'
        component_image_folder = fullfile(output_folder, strcat(curr_segment, '_component_images'));  %include study name
        if ~isdir(component_image_folder), mkdir(component_image_folder);end
        
        for comp_idx = mu_comps
            pop_prop_extended(EEG, 0, comp_idx)
            fn = strcat(curr_p, curr_segment, "_component_", num2str(comp_idx), '.png');
            saveas(gcf, fullfile(component_image_folder, fn));
        end
    otherwise
end

if ~isempty(mu_comps) %some participants don't have components that fit the criteria
    
    means_of_interest = mean(EEG.icawinv(:,mu_comps), 2);
    topo_vals = means_of_interest';
    
else
    topo_vals = [];
end

close all

end

