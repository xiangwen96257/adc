N = 10;      %ADC 分辨率（Bit）
fs = 10e6;   %ADC采样率（Hz）
Vref = 1.8;  %ADC参考电压（V）
Cu = 1e-15;  %ADC的单位电容（F）
sigmaCu = 0.0;%单位电容失配
C_arr = [2.^(N-1:-1:0),1].*Cu;%电容阵列
weight = 2.^(N-1:-1:0);
C_dev = sigmaCu*Cu*sqrt(C_arr/Cu).*randn(1,N+1);
C_arr = C_arr + C_dev;
C_arr_exact =(2.^(N-1:-1:0)).*Cu;
C_dev_exact = sigmaCu*Cu*sqrt(weight).*randn(1,N);
C_arr_exact = C_arr_exact + C_dev_exact;
C_tot = sum(C_arr);%总电容大小
num = 2^10;        %采样点数
fin = (1141/num)*fs; %输入信号频率（Hz）
ts = 1/fs;         %输入信号采样周期（s）
t = (0:1:num-1)*ts;%采样序列
Vin = Vref/2 + (Vref/2)*sin(2*pi*fin*t);%输入信号采样
Com_offset = 0.01;
Com_noise = 0.01*randn(1,1);
Dout = zeros(num,N);
Dout_single = zeros(1,N);
Vout = zeros(1,num);
for j=1:1:num
    Dout_single = zeros(1,N);
    for i=1:1:N
        Dout_single(i) = 1;
        Vx=-Vin(j)+dot(Dout_single,C_arr_exact)*Vref/C_tot;
        if Vx<=Com_offset+Com_noise
            Dout_single(i) = 1;
        else
            Dout_single(i) = 0;
        end
    end
    Dout(j,:)= Dout_single;
    Vout(1,j)= dot(Dout(j,:),weight);
end
V = Vout*Vref/2^N;
fft_out = abs(fft(V-mean(V))).^2;
fft_out = fft_out(1:num/2);
signal_power = max(fft_out); 
noise_power = (sum(fft_out) - signal_power);
SNDR = 10*log10( signal_power / noise_power );
ENOB_values = (SNDR - 1.76) / 6.02; 
figure;
plot(linspace(0, fs/2, num/2), 10*log10(fft_out));
xlabel('frequency (Hz)'); ylabel('power(dB)'); grid on;
dim = [0.15 0.75 0.1 0.1]; 
str = sprintf('SNDR: %.2f dB\nENOB: %.2f bits', SNDR, ENOB_values);
annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on', 'BackgroundColor', 'w', 'FontSize', 12);

