function  test2(Vref,N,C_arr_exact,C_tot,weight,gnd)
step = Vref / (2^N);
Vin = (0:0.01*step:Vref);
K = length(Vin);
Dout = zeros(K,N);
Vout = zeros(1,K);
for j=1:1:K
    Dout_single = zeros(1,N);
    for i=1:1:N
        Dout_single(i) = 1;
        Vx=-Vin(j)+dot(Dout_single,C_arr_exact)*Vref/C_tot;
        if Vx>=gnd
            Dout_single(i) = 0;
        else
            Dout_single(i) = 1;
        end
    end
    Dout(j,:)= Dout_single;
    Vout(1,j)= dot(Dout(j,:),weight);
end
V = Vout*Vref/(2^N);
uniqueElements = unique(V);
counts = histc(V, uniqueElements);

ideal_out =1:1:2^N;
dnl = (counts-mean(counts))/mean(counts);
inl = cumsum(dnl);

dnlmax= max(dnl);
dnlmin = min(dnl);
inlmax = max(inl);
inlmin = min(inl);

figure()
subplot( 2, 1, 1 ), plot( dnl );
grid on
xlabel( 'Output code' );
ylabel( 'LSB'         );
axis( [ 0, length( dnl ), min( dnl ) - 0.5, max( dnl ) + 0.5 ] );
a1= min( dnl );
a2= max( dnl );
string2=sprintf('DNL: %3.2f LSB / %3.2f LSB ',dnlmin, dnlmax);  
title(string2)

subplot( 2, 1, 2 ), plot( inl );
grid on
xlabel( 'Output code' );
ylabel( 'LSB'         );
axis( [ 0, length( inl ), min( inl ) - 0.5, max( inl ) + 0.5 ] );
string3=sprintf('lNL: %3.2f LSB / %3.2f LSB ',inlmin, inlmax);  
title(string3)
grid on