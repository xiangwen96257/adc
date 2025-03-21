function [V,Vout] = SAR_ADC_logic(Vref,fin,t,C_tot,C_arr_exact,num,weight,N,gnd)
Vin = Vref/2 + (Vref/2)*sin(2*pi*fin*t);
Dout = zeros(num,N);
Vout = zeros(1,num);
for j=1:1:num
    Dout_single = zeros(1,N);
    for i=1:1:N
        Dout_single(i) = 1;
        Vx = CDAC(Vin(j),Vref,C_tot,Dout_single,C_arr_exact);
        if Comparator(Vx,gnd)== 1
            Dout_single(i) = 0;
        else
            Dout_single(i) = 1;
        end
    end
    Dout(j,:)= Dout_single;
    Vout(1,j)= dot(Dout(j,:),weight);
end
V = Vout*Vref/2^N;
end