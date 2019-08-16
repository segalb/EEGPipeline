function mu_power = Brandon_FFT(EEG, options)

%decomposition code from Brandon
N  = length(EEG.data);
nyquist = EEG.srate/2;
frequencies = linspace(0,nyquist,N/2+1);
fourierCoefsF = fft(EEG.data') / N;
low = find(frequencies == options.pfreq_low);
high = find(frequencies == options.pfreq_high);
mu_power  = mean(abs(fourierCoefsF(low:high, :)).^2,1);

end