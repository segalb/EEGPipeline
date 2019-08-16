function Topographic_Maps(options)

%--first, gotta get a file to use as a chanloc model
try
    %go to segments folder
    cd(options.mySegmentsFolder);
    addpath(genpath(options.mySegmentsFolder)); %need this for which() to work
    %grab first seg you see
    example = dir('**/*.set');
    example = example(1).name;
    example = which(example);
    %load it
    EEG = pop_loadset('filename', example);
catch
    error('Do you have any .set files in the segments folder?')
end
EEG = EEG;
close all %need gui to be closed to not confuse figure saver

%--choose desired data
[subs, ttls] = Get_TTLs(options); %ignore subs

%--get desired data
switch options.ICA_power
    case 'off'
        input_folder = fullfile(options.power_folder, options.decomp);
    case 'on'
        input_folder = fullfile(options.power_folder, 'ICA_power');
    otherwise
end
cd(input_folder);

%--watch out for ttls where whose brain matters!
order_important_ttls = {':_partner_1s_positive_experience', ...
    ':_partner_1s_negative_experience', ...
    ':_partner_2s_positive_experience', ...
    ':_partner_2s_negative_experience',...
    ':_partner_1s_pre-interaction_ball_squeeze',  ...
    ':_partner_2s_pre-interaction_ball_squeeze', ...
    ':_partner_1s_post-interaction_ball_squeeze', ...
    ':_partner_2s_post-interaction_ball_squeeze'};

for seg = ttls
    
    switch options.ICA_power
        case 'off'
            fn = strcat(seg, '_POWER.mat');
        case 'on'
            fn = strcat(seg, '_Mu_Components.mat');
        otherwise
    end
    
    if exist(fn{:}, 'file')
        load(fn{:}) %retains name power_table
    else
        continue
    end
    keyboard
    switch options.ICA_power
        case 'off'
            
            if ismember(seg, order_important_ttls) %test if which partner matters
                
                %separate subs 1 and 2
                sub1 = power_table(power_table.subject < 2000, :);
                sub1 = sub1(:, 2:end);
                sub2 = power_table(power_table.subject > 2000, :);
                sub2 = sub2(:, 2:end);
                
                mean_figure_maker(sub1, EEG, strcat('Subject 1', seg), options);
                mean_figure_maker(sub2, EEG, strcat('Subject 2', seg), options);
                
            else
                
                power_table = power_table(:, 2:end); %cut off sub #s
                plot_title = seg;
                
                mean_figure_maker(power_table, EEG, plot_title, options)
            end
            
        case 'on'
            
                if ismember(seg, order_important_ttls) %test if which partner matters
                
                %separate subs 1 and 2
                sub1 = topo_table(topo_table(:, 1) < 2000, :);
                sub1 = sub1(:, 2:end);
                sub2 = topo_table(topo_table(:, 1) > 2000, :);
                sub2 = sub2(:, 2:end);
                
                mean_figure_maker(sub1, EEG, strcat('Subject 1', seg), options);
                mean_figure_maker(sub2, EEG, strcat('Subject 2', seg), options);
                
            else
                
                topo_table = topo_table(:, 2:end); %cut off sub #s
                plot_title = seg;
                
                mean_figure_maker(topo_table, EEG, plot_title, options)
            end
            
        otherwise
    end
    
end