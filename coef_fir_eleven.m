# --------------------------------------------------------------------------------------
# Calculo de coheficientes para filtro FIR LSE
# --------------------------------------------------------------------------------------

clc; clear all; close all;

pkg load signal  % Carga el paquete de procesamiento de señales en Octave

% Parámetros del filtro FIR
num_taps = 11;      % Número de coeficientes (taps) del filtro FIR
f_corte = 0.4;      % Frecuencia de corte normalizada (en términos de Nyquist)

% Definir los vectores de frecuencia y amplitud para 'firls'
% Vector de frecuencia [0, frecuencia de corte, frecuencia de transición, 1]
% Estos valores determinan la forma de la respuesta en frecuencia del filtro.
F = [0 f_corte f_corte+0.1 1];
% Vector de amplitud deseado en las bandas correspondientes
% Aquí definimos la amplitud para cada segmento de frecuencia.
A = [1 1 0 0];

% Diseño del filtro FIR usando el método de mínimos cuadrados (Least Squares Error)
coef = firls(num_taps - 1, F, A);

% Normalizar coeficientes para ajustarlos al rango de 8 bits signed
coef_fixed = round(coef * 2^(8-1));      % Escalado para tener precisión de 8 bits signed
coef_fixed(coef_fixed < -128) = -128;    % Límite inferior de 8 bits signed
coef_fixed(coef_fixed > 127) = 127;      % Límite superior de 8 bits signed

% Convertir a formato hexadecimal
% Convierte los coeficientes a hexadecimal para implementación en VHDL
coef_hex = dec2hex(typecast(int8(coef_fixed), 'uint8'));

% Mostrar los coeficientes en formato VHDL requerido
disp("constant coeficient: coeficient_type := ");
disp("    (");

for i = 1:length(coef_hex)
    % Mostrar cada coeficiente en hexadecimal, con prefijo X"
    fprintf('        X"%s"', coef_hex(i, :));
    if i < length(coef_hex)
        fprintf(",\n");
    else
        fprintf("\n");
    end
end
disp("    );");

% Graficar los coeficientes en el dominio del tiempo
figure;
subplot(3, 1, 1);
stem(0:num_taps-1, coef_fixed, 'filled', 'black');  % Color negro
title('Coeficientes del Filtro FIR (Tiempo)');
xlabel('Índice de Muestra');
ylabel('Amplitud');
grid on;

% Graficar la respuesta en frecuencia
[H, w] = freqz(coef, 1, 1024);  % Calcula la respuesta en frecuencia del filtro
subplot(3, 1, 2);
plot(w/pi, abs(H), 'red');  % Color rojo
title('Respuesta en Frecuencia del Filtro FIR');
xlabel('Frecuencia Normalizada (\times\pi rad/muestra)');
ylabel('Magnitud');
grid on;

% Graficar la respuesta de fase
subplot(3, 1, 3);
plot(w/pi, angle(H), 'green');  % Color green
title('Respuesta en Fase del Filtro FIR');
xlabel('Frecuencia Normalizada (\times\pi rad/muestra)');
ylabel('Fase (radianes)');
grid on;

