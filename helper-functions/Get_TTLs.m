function [subs, ttls] = Get_TTLs(options)

if strcmp(options.analysis_type, 'Dyad') == 1
    subs = cell(numel(options.Dyads) * 2, 1); %two people per dyad
    sub_count = 0;
    for S = 1:2:(numel(options.Dyads)*2)
        sub_count = sub_count + 1;
        subs{S} = options.Dyads(sub_count) + 1000;
        subs{S+1} = options.Dyads(sub_count) + 2000;
    end
    ttls = options.dyad_ttls.names;
end

if strcmp(options.analysis_type, 'Indiv') == 1
    subs = num2cell(options.Indivs);
    ttls = options.indiv_ttls.names;
end

if strcmp(options.analysis_type, 'Both') == 1
    subs = cell(numel(options.Dyads) * 2, 1); %two people per dyad
    sub_count = 0;
    for S = 1:2:(numel(options.Dyads)*2)
        sub_count = sub_count + 1;
        subs{S} = options.Dyads(sub_count) + 1000;
        subs{S+1} = options.Dyads(sub_count) + 2000;
    end
    subs_indiv = options.Indivs;
    subs = [subs{:}, subs_indiv];
    subs = unique(subs);
    subs = num2cell(subs)';
    ttls_dyad = options.dyad_ttls.names;
    ttls_ind = options.indiv_ttls.names;
    ttls = [ttls_dyad, ttls_ind];
end

