function save_figures_as(options, extension)

if nargin < 2
    extension = 'png';
end

switch options.ICA_power
    case 'on'
        input_folder = fullfile(options.power_folder, 'ICA_power');
    case 'off'
        input_folder = fullfile(options.power_folder, options.decomp);
end
cd(input_folder);

figures = dir('*.fig');
for fig = 1:length(dir('*.fig'))
    figure = openfig(figures(fig).name);
    fn = figures(fig).name;
    fn = strrep(fn, 'fig', extension);
    saveas(figure, fn);
    close all
end


end

