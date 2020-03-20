%% normal + Decimat
load('piciorus.mat')
close all;
clc;


t=double(piciorus.X.Data)';
d=double(piciorus.Y(1,3).Data)';
w=double(piciorus.Y(1,2).Data)'; %viteza unghiulara;
th=double(piciorus.Y(1,1).Data)'; %pozitia unghiulara;

figure;
subplot(311); plot(t,d); title('Intrarea u');
ylabel("Amplitudinea");
xlabel("Timp[sec]");
subplot(312); plot(t,w); title('Viteza unghiulara ?');
ylabel("Amplitudinea");
xlabel("Timp[sec]");
subplot(313); plot(t,th); title('Pozitia unghiulara ?');
ylabel("Amplitudinea");
xlabel("Timp[sec]");

figure;
plot(t,[d*100 w th]);
legend("Intrarea u*100","Viteza unghiulara ?","Pozitia unghiulara ?");
title("Comanda motor BLDC.Viteza unghiulara si pozitia.")
ylabel("Amplitudinea");
xlabel("Timp[sec]");
grid;


i1=317; i2=441; i3=4019; i4=4239; i5=7742; i6=7902;
i7=8626; i8=8633;

wi=w;
wi(i1:i2)=interp1([t(i1) t(i2)],[w(i1) w(i2)], t(i1:i2));
wi(i3:i4)=interp1([t(i3) t(i4)],[w(i3) w(i4)], t(i3:i4));
wi(i5:i6)=interp1([t(i5) t(i6)],[w(i5) w(i6)], t(i5:i6));
wi(i7:i8)=interp1([t(i7) t(i8)],[w(i7) w(i8)], t(i7:i8));
w=wi;
figure;

plot(t,[d*100 w th]);
legend("Intrarea u*100","Viteza unghiulara ?","Pozitia unghiulara ?");
title("Comanda motor BLDC.Viteza unghiulara si pozitia.")
ylabel("Amplitudinea");
xlabel("Timp[sec]");
grid;

figure;
subplot(311); plot(t,d); title('Intrarea d');
subplot(312); plot(t,w); title('Viteza unghiulara w');
subplot(313); plot(t,th); title('Pozitia unghiulara th');


plot(t,w);
Te=t(50)-t(49);


t1=418; t2=3735; t3=4198; t4=7368;

data_id_w=iddata(w(t1:t2),d(t1:t2),Te);
data_id_th=iddata(th(t1:t2),w(t1:t2),Te);

data_v_w=iddata(w(t3:t4),d(t3:t4),Te);
data_v_th=iddata(th(t3:t4),w(t3:t4),Te);

data_g_w=iddata(w,d,Te);
data_g_th=iddata(th,w,Te);

plot(t,w);
ii1=5945;
ii2=5950;


N=ii2-ii1+1;

t_dec=t(1:N:end);
d_dec=d(1:N:end);
w_dec=w(1:N:end);
th_dec=th(1:N:end);
Te_dec=Te*N;


figure;
plot(t_dec,w_dec);
legend("Viteza unghiulara ? decimata");
title("Comanda motor BLDC.Viteza unghiulara si pozitia.")
ylabel("Amplitudinea");
xlabel("Timp[sec]");



t1_dec=round(t1/N);
t2_dec=round(t2/N);
t3_dec=round(t3/N);
t4_dec=round(t4/N);



data_id_w_dec=iddata(w_dec(t1_dec:t2_dec),d_dec(t1_dec:t2_dec),Te_dec);
data_id_th_dec=iddata(th_dec(t1_dec:t2_dec),w_dec(t1_dec:t2_dec),Te_dec);

data_v_w_dec=iddata(w_dec(t3_dec:t4_dec),d_dec(t3_dec:t4_dec),Te_dec);
data_v_th_dec=iddata(th_dec(t3_dec:t4_dec),w_dec(t3_dec:t4_dec),Te_dec);

data_g_w_dec=iddata(w_dec,d_dec,Te_dec);
data_g_th_dec=iddata(th_dec,w_dec,Te_dec);

%% Corelatia cu IV


close all;
clc;

m_iv_w=iv4(data_id_w, [1 1 1]);     %
m_iv_th=iv4(data_id_th, [1 1 1]);   %[na,nb,nd]

figure; resid(m_iv_w, data_v_w,'corr',5);
figure; compare(m_iv_w, data_g_w);

figure; resid(m_iv_th, data_v_th,'corr',5);
figure; compare(m_iv_th, data_g_th);


%% OE + DEC
close all;
clc;

m_oe_w_dec=oe(data_id_w_dec, [1 1 1]);      %
m_oe_th_dec=oe(data_id_th_dec, [1 1 1]);    % [na,nb,nd]

figure; resid(m_oe_w_dec, data_v_w_dec);
figure; compare(m_oe_w_dec, data_g_w_dec);

figure; resid(m_oe_th_dec, data_v_th_dec);
figure; compare(m_oe_th_dec, data_g_th_dec);
%% Autocorelatia cu Armax decimat

close all;
clc;

m_armax_w_dec=armax(data_id_w_dec, [1 1 1 1]);  %
m_armax_th_dec=armax(data_id_th_dec, [1 1 1 1]);% [na,nb,nc,nd]

figure; resid(m_armax_w_dec, data_v_w_dec,"corr",10);
figure; compare(m_armax_w_dec, data_g_w_dec);

figure; resid(m_armax_th_dec, data_v_th_dec,"corr",10);
figure; compare(m_armax_th_dec, data_g_th_dec);


%% Transfer Function 


close all 
clc;

Hd_iv_w_d=tf(m_iv_w);
Hd_iv_th_w=tf(m_iv_th);
ki=0.002052/Te;

H_iv_w_d=d2c(Hd_iv_w_d,'zoh');
H_iv_th_w=tf([ki],[1 0]);

H_iv_thd=series(H_iv_w_d,H_iv_th_w)


Hd_armax_dec_w_d=tf(m_armax_w_dec);
Hd_armax_dec_th_w=tf(m_armax_th_dec);
kii=0.09671/Te_dec;

H_armax_dec_w_d=d2c(Hd_armax_dec_w_d,'zoh');
H_armax_dec_th_w=tf([kii],[1 0]);

H_armax_thd=series(H_armax_dec_w_d,H_armax_dec_th_w)






