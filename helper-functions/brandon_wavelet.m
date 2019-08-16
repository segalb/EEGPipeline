function power = brandon_wavelet(EEG, options)

num_frex = options.lowpass + 1 - options.highpass;  %set to 1 Hz bins
frex = linspace(options.highpass,options.lowpass,num_frex);
low = find(frex == options.pfreq_low);
high = find(frex == options.pfreq_high);
time = -2:1/EEG.srate:2;
half_wav = (length(time)-1)/2;
nKern = length(time);
nData = EEG.pnts*EEG.trials;
nConv = nKern+nData-1;
range_cycles = [5 10];  %ranges from 5 to 10. can play with, test how much it matters
nCycles = logspace(log10(range_cycles(1)),log10(range_cycles(end)),num_frex);
cmwX = zeros(num_frex,nConv);
for fi=1:num_frex
    s       =  nCycles(fi) / (2*pi*frex(fi));% frequency-normalized width of Gaussian
    cmw      = exp(1i*2*pi*frex(fi).*time) .* exp( (-time.^2) ./ (2*s^2) );
    tempX     = fft(cmw,nConv);
    cmwX(fi,:) = tempX ./ max(tempX);
end

power = NaN(EEG.nbchan, 1);
channels = {EEG.chanlocs.labels};

for chan_idx = 1:EEG.nbchan
    
    channel2use = channels{chan_idx};
    
    % FFT of data (doesn't change on frequency iteration)
    dataX = fft(reshape(EEG.data(strcmpi(channel2use,{EEG.chanlocs.labels}),:,:),1,[]),nConv);
    
    for fi=1:length(frex)
        
        % run convolution
        as = ifft(dataX.*cmwX(fi,:));
        as = as(half_wav+1:end-half_wav);
        as = reshape(as,EEG.pnts,EEG.trials);
        % put power data into big matrix
        tf(fi,:) = mean(abs(as).^2,2);
        
    end
    
    power(chan_idx) = mean(mean(log(tf(low:high,:)), 2));
    
end



end