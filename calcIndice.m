function [index, valalpha, valbeta] = calcIndice(X, palphaini, palphafin, pbetaini, pbetafin)

% Calcula el ratio beta/alpha:
%   X   :   señal transformada.
%   Xr  :   Parte real de la transformada.
%   Xi  :   Parte imaginaria de la transformada.
%   palphaini : posicion de la tranformada correspondiente al comienzo de
%   alpha (8Hz).
%   palphafin : posicion de la transformada correspondiente al final de
%   alpha (13Hz).
%   pbetaini, pbetafin : posicion inicio (14 Hz) y final (19Hz) de beta.


    Xalpha = X(palphaini:palphafin);
    Xbeta = X(pbetaini:pbetafin);

    valalpha= mean(abs(Xalpha).^2);
    valbeta = mean(abs(Xbeta).^2);
    
%     valalpha= max(abs(Xalpha).^2);
%     valbeta = max(abs(Xbeta).^2);
    index = valbeta/valalpha;

    %plot(valbeta); hold on; plot(valalpha,'r');
 
end