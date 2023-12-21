%% FUNCION PARA LEER GRABACIONES DE EEG DE AMBAS PLACAS:
% PP : placa propia
% OPB : OpenBCI


function [open, closed] = readFiles(sujeto, numFiles, placa)
    
    % Variables generales de la funcion.
    
    task_duration = 60;
    channels = [2,3];
    
    if strcmp(placa, 'OPB')
        ini = 5;
        fs = 250;
        path = strcat(strcat('../../Grabaciones/', sujeto),'/OPB/OpenBCI-RAW-');
        extension = '.txt';
    elseif strcmp(placa, 'PP')
        ini = 2;
        fs = 200;
        path = strcat(strcat('../../Grabaciones/', sujeto),'/PP/');
        extension = '.csv';
    end
    
    % Variables donde almacenar los registros EEG.
    closed = zeros(0,length(channels));
    open = zeros(0,length(channels));
    
    
    for i=1:numFiles
        % Cargamos los archivos de cerrados y abiertos.
        file = strcat(strcat(strcat(strcat(strcat(path,'cerrados'),num2str(i)),'_'),sujeto),extension);
        cl = load(file);
        
        file = strcat(strcat(strcat(strcat(strcat(path,'abiertos'),num2str(i)),'_'),sujeto),extension);
        op = load(file);
        
        % Seleccionamos los datos utiles de la grabacion.
        cl = cl(ini*fs:ini*fs+task_duration*fs-1,channels);
        op = op(ini*fs:ini*fs+task_duration*fs-1,channels);
        
        cl = cl - mean(cl,1);
        op = op - mean(op,1);
        
        % Concatenamos los datos con los previamente leidos.
        closed = [closed;cl];
        open = [open;op];
     
    end
end