% -------- Especificaciones -------- %
fp = [800 1250];     % Banda de paso (Hz)
fs = [200 5000];     % Banda de rechazo (Hz)

Rp = 0.25;   % Ripple en banda de paso (dB)
Rs = 30;     % Atenuación en banda de rechazo (dB)

% Conversión a rad/s
Wp = 2*pi*fp;
Ws = 2*pi*fs;

%% ======== Filtro pasa banda ======== %%
[n, Wn] = cheb1ord(Wp, Ws, Rp, Rs, 's');
[b, a] = cheby1(n, Rp, Wn, 'bandpass', 's');
H = tf(b, a);

disp(['Orden del filtro: ', num2str(n)])

%% ====== Descomposición en SOS (bicuadratica) ====== %%
[sos, g] = tf2sos(b, a);

% Secciones de segundo orden
H1 = tf(sos(1,1:3), sos(1,4:6));
H2 = tf(sos(2,1:3), sos(2,4:6));

% Aplicar ganancia total al primer bloque
H1 = g * H1;

% Verificación
H_reconstruido = series(H1, H2)

%% ====== Identificación automática ====== %%
% Evaluamos en baja frecuencia para distinguir HPF vs LPF

w_test = 2*pi*100;

[mag1, ~] = bode(H1, w_test);
[mag2, ~] = bode(H2, w_test);

mag1 = squeeze(mag1);
mag2 = squeeze(mag2);

if mag1 < mag2
    H_hp = H1
    H_lp = H2
else
    H_hp = H2
    H_lp = H1
end

%% ====== Respuesta en frecuencia ====== %%
w = logspace(1,5,2000);

[mag_bp, ~] = bode(H, w);
[mag_hp, ~] = bode(H_hp, w);
[mag_lp, ~] = bode(H_lp, w);
[mag_rec, ~] = bode(H_reconstruido, w);

mag_bp = squeeze(mag_bp);
mag_hp = squeeze(mag_hp);
mag_lp = squeeze(mag_lp);
mag_rec = squeeze(mag_rec);

f = w/(2*pi);

%% ====== Gráfica ====== %%
figure
semilogx(f, 20*log10(mag_bp), 'LineWidth', 2)
hold on
semilogx(f, 20*log10(mag_hp), '--', 'LineWidth', 1.5)
semilogx(f, 20*log10(mag_lp), '--', 'LineWidth', 1.5)
semilogx(f, 20*log10(mag_rec), ':', 'LineWidth', 2)

grid on
xlabel('Frecuencia (Hz)')
ylabel('Magnitud (dB)')
title('Descomposición del Filtro Pasa Banda en Bicuadraticas')

legend('Pasa Banda original', ...
       'Pasa Alto (bicuadratica)', ...
       'Pasa Bajo (bicuadratica)', ...
       'Reconstrucción (H1 * H2)')
