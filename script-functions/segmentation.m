
function segmentation(options)

if ~isdir(options.mySegmentsFolder) %make place for cleaned files if it doesn't alreadly exist
    mkdir(options.mySegmentsFolder)
end
addpath(options.mySegmentsFolder);

dyad_ttls = options.dyad_ttls;
indiv_ttls = options.indiv_ttls;

missing_TTLs = fopen(fullfile(options.save_dir, 'Missing_and_additional_TTLs.txt'), 'w');

Ps = [1 2]; %do everything for both participants in dyad

%--Dyad segmentation
if strcmp(options.analysis_type, 'Indiv') ~= 1
    for dyad_idx=options.Dyads
        for p = Ps
            if ismember(strcat(num2str(dyad_idx), '.vhdr'), options.present_files)
                if ~ismember(dyad_idx, options.exclusions)
                    
                    Dyad_segmenter(dyad_ttls, dyad_idx, p, missing_TTLs, options);
                end
            end
        end
    end
end

%--Indiv segmentation
if strcmp(options.analysis_type, 'Dyad') ~= 1
    for sub_idx=options.Indivs
        if ~ismember(sub_idx, options.exclusions)
            
            Indiv_segmenter(sub_idx, missing_TTLs, options, indiv_ttls);
        end
    end
end

fclose(missing_TTLs);

end
