function Vx = CDAC(Vinj,Vref,C_tot,Dout_single,C_arr_exact)
Vx=-Vinj+dot(Dout_single,C_arr_exact)*Vref/C_tot;
end