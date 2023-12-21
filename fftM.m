function [X, Xr, Xi] = fftM(x,met)

% Realiza las transformadas sobre la señal x.
%   x   :   señal EEG de entrada.
%   met :   Transformada a utilizar (1-4).
  
  L = length(x);
  n = 0:L-1; 
  m = n;
  
  if met == 1
%     Xr =  cos(2*pi*(m')*n/L)*x;
%     Xi =  -sin(2*pi*(m')*n/L)*x;
    Xr = real(fft(x));
    Xi = imag(fft(x));
  elseif met == 2
    Xr = sign(cos(2*pi*(m')*n/L))*x;
    Xi = -sign(sin(2*pi*(m')*n/L))*x;
  elseif met == 3
    Xr = cos(2*pi*(m')*n/L)*x;
    Xi = zeros(L,1);
  elseif met == 4
    Xr = sign(cos(2*pi*(m')*n/L))*x;
    Xi = zeros(L,1);
  end;
  
  X = Xr + j*Xi;
  
 