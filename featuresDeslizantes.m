function [index_acum_cl, index_acum_op] = featuresDeslizantes(closed, open, desp, fs, tam_ventana, met)
    
    % Variables generales.
    muestras_ventana = tam_ventana * fs;
    falphainf = 8; falphasup = 12;
    fbetainf = 13; fbetasup = 17;
    
    % Determinamos las frecuencias de alpha y beta.
    freq = fs*(0:(muestras_ventana/2))/muestras_ventana;

    palphaini = find(freq==falphainf);
    palphafin = find(freq==falphasup);
    pbetaini =  find(freq==fbetainf);
    pbetafin = find(freq==fbetasup);
    
    % Calculamos el numero de ventanas.
    num_ventanas = fix((size(open,1) - tam_ventana*(1-desp)*fs)/((tam_ventana-(1-desp)*tam_ventana)*fs));
    
    index_acum_cl = zeros(num_ventanas, 1);
    index_acum_op = zeros(num_ventanas, 1);
    
    for i = 0:num_ventanas-1
        ini = i*fix(muestras_ventana*desp)+1;
        fin = i*fix(muestras_ventana*desp)+muestras_ventana;
        
        % Cerrados
        x_cl = closed(ini:fin, 1);
%         X_cl = fft(x_cl,[],1);
        [X_cl, Xr, Xi] = fftM(x_cl, met);
        [id1,~,~] = calcIndice(X_cl(:,1),palphaini,palphafin,pbetaini,pbetafin);
%         [id2,~,~] = calcIndice(X_cl(:,2),palphaini,palphafin,pbetaini,pbetafin);
        index_acum_cl(i+1) = [id1];
        
        % Abiertos
        x_op = open(ini:fin,1);
%         X_op = fft(x_op,[],1);
        [X_op, Xr, Xi] = fftM(x_op, met);
        [id1,~,~] = calcIndice(X_op(:,1),palphaini,palphafin,pbetaini,pbetafin);
%         [id2,~,~] = calcIndice(X_op(:,2),palphaini,palphafin,pbetaini,pbetafin);
        index_acum_op(i+1) = [id1];
    end
end