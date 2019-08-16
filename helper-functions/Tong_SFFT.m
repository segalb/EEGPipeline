function mu_power = Tong_SFFT(EEG, window_length, overlap, options)

specto_issue = fopen(fullfile(options.save_dir, 'Spectogram_Fails.txt'), 'w');

if mod(ceil(EEG.xmax), window_length) ~= 0 %deal with diff length segs
    window_length = 2.5;
end

window_pts = EEG.srate * window_length;
b = window_pts/EEG.srate;
c = options.pfreq_high*b;
d = options.pfreq_low*b;

mu_power = NaN(EEG.nbchan, 1);

for chan_idx = 1:EEG.nbchan
    
    try
        chan_spec = spectrogram(EEG.data(chan_idx, :), hann(window_pts), overlap * window_pts);
    catch
        fprintf(specto_issue, '\n\nchannel %g removed due to specto issue', chan_idx);
        continue
    end
    fft_chan = chan_spec(d:c, :);
    pow_chan = mean(mean(abs(fft_chan).^2, 1));
    
    mu_power(chan_idx, 1) = pow_chan;
    
end

end