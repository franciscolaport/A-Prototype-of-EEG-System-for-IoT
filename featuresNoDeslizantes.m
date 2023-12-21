function [index_acum_cl, index_acum_op] = featuresNoDeslizantes(closed, open, fs, tam_ventana, met)

    muestras_ventana = tam_ventana * fs;
    falphainf = 8; falphasup = 12;
    fbetainf = 13; fbetasup = 17;
    num_ventanas = floor(size(open,1)/muestras_ventana);

    % Buscamos los puntos donde empiezan y terminan alpha y beta.
    freq = fs*(0:(muestras_ventana/2))/muestras_ventana;
    palphaini = find(freq==falphainf);
    palphafin = find(freq==falphasup);
    pbetaini =  find(freq==fbetainf);
    pbetafin = find(freq==fbetasup);

    index_acum_cl = zeros(num_ventanas, size(closed,2));
    index_acum_op = zeros(num_ventanas, size(open,2));

    for v = 1:num_ventanas
        % Inicio y final de la ventana.
        ini_ventana = (v-1)*muestras_ventana + 1;
        fin_ventana = ini_ventana + muestras_ventana - 1;

        % Datos ojos cerrados.
        x_cl = closed(ini_ventana:fin_ventana,:);
%         X_cl = fft(x_cl,[],1);
        [X_cl, Xr, Xi] = fftM(x_cl, met);
        [id1,~,~] = calcIndice(X_cl(:,1),palphaini,palphafin,pbetaini,pbetafin);
%         [id2,~,~] = calcIndice(X_cl(:,2),palphaini,palphafin,pbetaini,pbetafin);
        index_acum_cl(v,:) = id1;

        % Datos ojos abiertos.
        x_op = open(ini_ventana:fin_ventana,:);
%         X_op = fft(x_op,[],1);
        [X_op, Xr, Xi] = fftM(x_op, met);
        [id1,~,~] = calcIndice(X_op(:,1),palphaini,palphafin,pbetaini,pbetafin);
%         [id2,~,~] = calcIndice(X_op(:,2),palphaini,palphafin,pbetaini,pbetafin);
        index_acum_op(v,:) = id1;

    end
end