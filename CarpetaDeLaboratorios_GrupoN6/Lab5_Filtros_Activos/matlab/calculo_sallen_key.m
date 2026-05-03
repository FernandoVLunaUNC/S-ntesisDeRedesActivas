clc; clear; close all;

% -------- Funciones de transferencia objetivo -------- %

% HPF
num_hp = [1 0 0];
den_hp = [1 1896 2.35e7];

% LPF
num_lp = [1.642e7];
den_lp = [1 3184 6.632e7];

H_hp = tf(num_hp, den_hp);
H_lp = tf(num_lp, den_lp);

%% ============================================= %%
% -------- PARAMETROS -------- %

% HPF
w0_hp = sqrt(den_hp(3));
Q_hp  = w0_hp / den_hp(2);

%LPF
w0_lp = sqrt(den_lp(3));
Q_lp  = w0_lp / den_lp(2);

fprintf('HPF: w0 = %.2f rad/s, Q = %.3f\n', w0_hp, Q_hp);
fprintf('LPF: w0 = %.2f rad/s, Q = %.3f\n', w0_lp, Q_lp);

%% ============================================= %%
% -------- HPF (k = 1) -------- %

C_hp = 1e-6;
k_hp = 1;

R2_hp = 2 / (C_hp * (w0_hp/Q_hp));
R1_hp = 1 / ( (w0_hp^2) * (C_hp^2) * R2_hp );

fprintf('\n--- HPF ---\n');
fprintf('C1 = C2 = %.2e F\n', C_hp);
fprintf('R1 = %.2f ohm\n', R1_hp);
fprintf('R2 = %.2f ohm\n', R2_hp);

%% ============================================= %%
% -------- LPF (k ≠ 1) -------- %

C_lp = 0.1e-6;

CR_lp = 1 / w0_lp;
k_lp = 3 - (w0_lp/Q_lp)*CR_lp;

R_lp = CR_lp / C_lp;

fprintf('\n--- LPF ---\n');
fprintf('C1 = C2 = %.2e F\n', C_lp);
fprintf('R1 = R2 = %.2f ohm\n', R_lp);
fprintf('k = %.3f\n', k_lp);

%% ============================================= %%
% -------- GANANCIA Y ESCALADO -------- %

G_real = k_lp / (C_lp^2 * R_lp^2);
G_deseada = 1.642e7;

G_corr = G_deseada / G_real;

fprintf('\n--- ESCALADO ---\n');
fprintf('Ganancia obtenida = %.3e\n', G_real);
fprintf('Factor correccion = %.5f\n', G_corr);

%% ============================================= %%
% -------- DIVISOR RESISTIVO --------%

syms R3 R4;

eq1 = R_lp == (R3*R4)/(R3+R4);
eq2 = G_corr == R4/(R3+R4);

sol = solve([eq1, eq2], [R3, R4]);

R3 = double(sol.R3);
R4 = double(sol.R4);

fprintf('\n--- DIVISOR ---\n');
fprintf('R3 = %.2f ohm\n', R3);
fprintf('R4 = %.2f ohm\n', R4);

%% ============================================= %%
% -------- GANANCIA OPAMP LPF -------- %

Rb = 1000;
Ra = Rb/(k_lp-1);

fprintf('\n--- OPAMP LPF ---\n');
fprintf('Ra = %.2f ohm\n', Ra);
fprintf('Rb = %.2f ohm\n', Rb);

%% ============================================= %%
% ---- FUNCIONES DE TRANSFERENCIA DE LOS FILTROS ---- %

% HPF
num_hp_sk = [1 0 0];
den_hp_sk = [1 (w0_hp/Q_hp) w0_hp^2];
H_hp_sk = tf(num_hp_sk, den_hp_sk);

% LPF
num_lp_sk = G_corr * k_lp/(C_lp^2 * R_lp^2);
den_lp_sk = [1 (w0_lp/Q_lp) w0_lp^2];
H_lp_sk = tf(num_lp_sk, den_lp_sk);

% TOTAL
H_total = series(H_hp, H_lp);
H_total_sk = series(H_hp_sk, H_lp_sk);

%% ============================================= %%
% -------- RESPUESTA EN FRECUENCIA -------- %

w = logspace(2,5,2000);

[mag_hp, ~] = bode(H_hp, w);
[mag_hp_sk, ~] = bode(H_hp_sk, w);

[mag_lp, ~] = bode(H_lp, w);
[mag_lp_sk, ~] = bode(H_lp_sk, w);

[mag_total, ~] = bode(H_total, w);
[mag_total_sk, ~] = bode(H_total_sk, w);

mag_hp = squeeze(mag_hp);
mag_hp_sk = squeeze(mag_hp_sk);

mag_lp = squeeze(mag_lp);
mag_lp_sk = squeeze(mag_lp_sk);

mag_total = squeeze(mag_total);
mag_total_sk = squeeze(mag_total_sk);

f = w/(2*pi);

%% ============================================= %%
% -------- GRAFICO COMPARACION FILTRO TOTAL -------- %

figure
semilogx(f, 20*log10(mag_total), 'LineWidth',2)
hold on
semilogx(f, 20*log10(mag_total_sk), '--','LineWidth',2)

grid on
title('Filtro Total')
xlabel('Frecuencia (Hz)')
ylabel('Magnitud (dB)')
legend('Original','Sallen-Key')

%% ============================================= %%
% -------- GRAFICO DE FILTROS COMBINADO  -------- %

figure
semilogx(f, 20*log10(mag_hp_sk), '--')
hold on
semilogx(f, 20*log10(mag_lp_sk), '--')
semilogx(f, 20*log10(mag_total_sk), 'LineWidth',2)

grid on
title('Descomposición del filtro')
xlabel('Frecuencia (Hz)')
ylabel('Magnitud (dB)')
legend('HPF','LPF','Total')