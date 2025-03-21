N = 10;      % ADC 分辨率（Bit）
fs = 10e6;   % ADC 采样率（Hz）
Vref = 1.8;  % ADC 参考电压（V）
Cu = 1e-15;  % ADC 的单位电容（F）
sigmaCu = 0.0; % 单位电容失配
num_sim = 10000; % 蒙特卡洛仿真次数
num = 2^10;  % 采样点数
fin = (1141/num)*fs; % 输入信号频率（Hz）
ts = 1/fs;   % 采样周期
t = (0:1:num-1)*ts; % 采样序列
Vin = Vref/2 + (Vref/2)*sin(2*pi*fin*t); % 输入信号
weight = 2.^(N-1:-1:0);
Com_offset = 0.006;
SNDR_results = zeros(1, num_sim);
ENOB_results = zeros(1, num_sim);

for sim = 1:num_sim
    Com_noise = 0.01*randn(1,1);
    % 重新生成电容失配误差
    C_arr = [2.^(N-1:-1:0),1].*Cu;
    C_dev = sigmaCu*Cu*sqrt(C_arr/Cu).*randn(1,N+1);
    C_arr = C_arr + C_dev;
    C_arr_exact = (2.^(N-1:-1:0)).*Cu;
    C_dev_exact = sigmaCu*Cu*sqrt(weight).*randn(1,N);
    C_arr_exact = C_arr_exact + C_dev_exact;
    C_tot = sum(C_arr);
    
    % SAR ADC 量化
    Dout = zeros(num, N);
    Vout = zeros(1, num);
    for j = 1:num
        Dout_single = zeros(1, N);
        for i = 1:N
            Dout_single(i) = 1;
            Vx = -Vin(j) + dot(Dout_single, C_arr_exact) * Vref / C_tot;
            if Vx <= Com_offset+Com_noise
                Dout_single(i) = 1;
            else
                Dout_single(i) = 0;
            end
        end
        Dout(j, :) = Dout_single;
        Vout(1, j) = dot(Dout(j, :), weight);
    end
    
    % 计算 SNDR 和 ENOB
    V = Vout * Vref / 2^N;
    fft_out = abs(fft(V - mean(V))).^2;
    fft_out = fft_out(1:num/2);
    signal_power = max(fft_out);
    noise_power = (sum(fft_out) - signal_power);
    SNDR = 10*log10(signal_power / noise_power);
    ENOB_values = (SNDR - 1.76) / 6.02;

    % 存储结果
    SNDR_results(sim) = SNDR;
    ENOB_results(sim) = ENOB_values;
end

% 结果可视化
figure;
subplot(2,1,1);
histogram(SNDR_results);
xlabel('SNDR (dB)'); ylabel('Count'); grid on;
title('SNDR 分布');

subplot(2,1,2);
histogram(ENOB_results);
xlabel('ENOB (bits)'); ylabel('Count'); grid on;
title('ENOB 分布');

% 计算均值和标准差
SNDR_mean = mean(SNDR_results);
SNDR_std = std(SNDR_results);
ENOB_mean = mean(ENOB_results);
ENOB_std = std(ENOB_results);

% 显示统计数据
fprintf('SNDR 平均值: %.2f dB, 标准差: %.2f dB\n', SNDR_mean, SNDR_std);
fprintf('ENOB 平均值: %.2f bits, 标准差: %.2f bits\n', ENOB_mean, ENOB_std);
