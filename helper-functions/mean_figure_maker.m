function mean_figure_maker(table_of_interest, EEG, plot_title, options)

if ~isempty(table_of_interest)
    means_of_interest = simple_power_means(table_of_interest, options);
    
    figure
    topoplot(means_of_interest, EEG.chanlocs);
    title(plot_title);
    colorbar
    
    fn = strcat(plot_title, '.fig');
    savefig(gcf, fn{:})
    close all
end

end

