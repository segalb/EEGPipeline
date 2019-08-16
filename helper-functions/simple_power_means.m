function power_means = simple_power_means(table, options)
%this deals with a participant x electrode power matrix

%default option in case of no options
if nargin < 2
    options.n_elec = 33;
end

if istable(table)
    mu_power = NaN(height(table), options.n_elec);
    for row = 1:height(table)
        mu_power(row, :) = table{row, :};
    end
else
    mu_power = table;
end

power_means = nanmean(mu_power, 1);

end
