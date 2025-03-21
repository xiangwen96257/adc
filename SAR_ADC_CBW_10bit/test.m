function [ENOB,SNDR] = test(V,num,fs)
fft_out = abs(fft(V-mean(V))).^2;
fft_out = fft_out(2:num/2+1);
signal_power = max(fft_out); 
noise_power = (sum(fft_out) - signal_power);
SNDR = 10*log10( signal_power / noise_power );
ENOB = (SNDR - 1.76) / 6.02; 
figure;
plot(linspace(0, fs/2, num/2), 10*log10(fft_out));
xlabel('frequency (Hz)'); ylabel('power(dB)'); grid on;
dim = [0.15 0.75 0.1 0.1]; 
str = sprintf('SNDR: %.2f dB\nENOB: %.2f bits', SNDR, ENOB);
annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on', 'BackgroundColor', 'w', 'FontSize', 12);
