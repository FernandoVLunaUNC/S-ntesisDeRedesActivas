% Especificaciones
fp = [800 1250];     % Banda de paso (Hz)
fs = [200 5000];     % Banda de rechazo (Hz)

Rp = 0.25;   % Ripple en banda de paso (dB)
Rs = 30;     % Atenuación en banda de rechazo (dB)

% Conversión a rad/s
Wp = 2*pi*fp;
Ws = 2*pi*fs;

% Orden mínimo del filtro Chebyshev tipo I
[n, Wn] = cheb1ord(Wp, Ws, Rp, Rs, 's');

% Diseño del filtro pasa banda
[b, a] = cheby1(n, Rp, Wn, 'bandpass', 's');

% Función de transferencia
H = tf(b, a);

% Mostrar resultados
disp(['Orden del filtro: ', num2str(n)]);
H;

% Respuesta en frecuencia
w = logspace(1,5,1000);
[mag, ~] = bode(H, w);
mag = squeeze(mag);

figure
semilogx(w/(2*pi), 20*log10(mag))
grid on
xlabel('Frecuencia (Hz)')
ylabel('Magnitud (dB)')
title('Filtro Chebyshev Tipo I - Pasa Banda')