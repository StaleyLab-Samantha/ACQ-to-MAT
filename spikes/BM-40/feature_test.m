
% Samantha Kumarasena, Jan 2017
% Looking at possibilities for features distinguishing spikes, seizures, and 
% artifacts. These possibilities include:
%    - PSD: ie. periodogram() from the Signal Processing Toolbox
%    - FFT
%    - Autocorrelation: ie. autocorr()


%% Loads data from file
clear all;
filename = 'BM40_spk2.mat';
load(filename);

fs = 500;                           % Sampling frequency of data: 500 Hz

%% Estimates and plots power spectral density (PSD) for both channels on the same plot.

% periodogram(data);                      % plots in dB per unit frequency (normalized)

figure;                                   % plots saved data, in dB, non-normalized freq
[pxx, f] = periodogram(data, [], [], fs);       
plot(f, 10*log10(pxx));
hold on;
xlabel('Frequency (Hz)');
ylabel('dB');
title('Power Spectral Density Estimate');
legend('Channel 1', 'Channel 2');
hold off;


%% Plots Fourier transform of both channels on the same plot.

T = 1/fs;                               % Sampling period
L = length(data);                       % Length of signal
t = (0:L-1)*T;                          % Time vector
f = fs*(0:(L/2))/L;                     % Frequency vector

Y = fft(data);                          % Calculating FFT
[row col] = size(Y);

fourier = f';

colors = ['r' 'b' 'c' 'm' 'k'];

figure;
% For each channel, obtain 1-side spectrum from double-sided
for i = 1:col
    
    ch = Y(:,i);                        % Single channel data
   
    P2 = abs(ch/L);                     % Two-sided spectrum                      
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    
    colindex = mod(i, length(colors));
    color = colors(colindex);
    
    plot(f, P1, 'color', color);        % Plot channel FFT in random color
    
    fourier = [fourier P1];
    
    hold on;
   
end;

xlabel('Frequency (Hz)');
ylabel('FFT');
title('FFT Plot of Data');
legend('Channel 1', 'Channel 2');
hold off;


%% Calculating and plotting autocorrelation

%{

%calculate and plot autocorr data for first channel
autocorr(data(:,1));
hold on; 

%find the stem plot within the plot, color it blue
h = findobj(gca, 'Type', 'stem');
h.Color = 'blue';                       %so we can distinguish it from the other channel

%calculate and plot autocorr data for second channel
autocorr(data(:,2));                    %autocorr plots red by default
hold off;

%}

%calculate autocorr data for both channels 
[acf1, lags1, bounds1] = autocorr(data(:,1), 100);
[acf2, lags2, bounds2] = autocorr(data(:,2), 100);

%plotting autocorr data
if(lags1 == lags2)                       %if... then can plot both autocorrs on the same plot
    figure;
    stem(lags1, acf1, 'r');              % plot first channel data
    hold on;
    plot(get(gca,'xlim'), [bounds1(1), bounds1(1)], 'r'); % plot bounds, adapting to x-lim of current axes
    plot(get(gca,'xlim'), [bounds1(2), bounds1(2)], 'r'); % plot bounds
   
    stem(lags2, acf2, 'b');              % plot second channel data
    plot(get(gca,'xlim'), [bounds2(1), bounds2(1)], 'b'); % plot bounds
    plot(get(gca,'xlim'), [bounds2(2), bounds2(2)], 'b'); % plot bounds
    
    xlabel('Lag');
    ylabel('Autocorrelation');
    title('Autocorrelation Plot for Both Channels');
    legend('Channel 1', 'CH1 Bounds', 'CH1 Bounds', 'Channel 2', 'CH2 Bounds', 'CH2 Bounds');
    hold off;
end

%% Save relevant PSD, FFT, and autocorr variables
savefile = strcat(filename, '-feat.mat');
save(savefile, 'psd', 'fourier', 'auto', 'bounds');





