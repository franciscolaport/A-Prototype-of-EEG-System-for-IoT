clear all;

% General variables.
sujeto = {'Fran'};
placa = 'PP';
num_files = 5;
files_idx = 1:num_files;
channels = 2;
task_duration = 60;
falphainf = 8; falphasup = 12;
fbetainf = 13; fbetasup = 17;
plot_perf = 0;

if strcmp(placa, 'PP')
    fs = 200;
elseif strcmp(placa,'OPB')
    fs = 250;
end

% Classification variables.
tam_ventana = 10;
muestras_ventana = tam_ventana * fs;
train_rec = 2;
train_duration = train_rec*task_duration; % sec.
ciclos = 5; % croosvalidation cycles.
rng(28);

% Correction vbs.
vent_correc = 1;

% Window scrolling percentage: 10%, 20% ...
desp = 0.2:0.2:0.8;

for met = 1:4
    for s = 1:length(sujeto)
        fprintf('MET %d - Subject %d \n', met, s);

        % Read the files
        [open, closed] = readFiles(sujeto{s}, num_files, placa);

        %% TRAINING
        for k = 1:ciclos
            fprintf('CICLO %d \n', k);
            % Select train and test recordings.
            [cv_train, cv_test] = crossvalind('HoldOut', num_files, (num_files-train_rec)/num_files);
            test_idx = files_idx(cv_test);
            train_idx = files_idx(cv_train);

            xtr_cl = zeros(length(train_idx)*task_duration*fs, length(channels));
            xtr_op = zeros(length(train_idx)*task_duration*fs, length(channels));

            % Select train recordings
            for i = 0:length(train_idx)-1
                ini = (train_idx(i+1)-1)*fs* task_duration+1;
                fin = ini+task_duration*fs-1;
                xtr_cl(i*fs*task_duration+1:(i+1)*fs*task_duration,:) = closed(ini:fin, 1); % data closed
                xtr_op(i*fs*task_duration+1:(i+1)*fs*task_duration,:) = open(ini:fin, 1);   % data open
            end
            
            xtest_cl = zeros(length(test_idx)*task_duration*fs, length(channels));
            xtest_op = zeros(length(test_idx)*task_duration*fs, length(channels));

            % Select test recordings.
            for i = 0:length(test_idx)-1
                ini = (test_idx(i+1)-1)*fs* task_duration+1;
                fin = ini+task_duration*fs-1;
                xtest_cl(i*fs*task_duration+1:(i+1)*fs*task_duration,:) = closed(ini:fin, 1); % data closed
                xtest_op(i*fs*task_duration+1:(i+1)*fs*task_duration,:) = open(ini:fin, 1);   % data open
            end
            
            
            for d = 1:length(desp)
                t_ventana = floor(tam_ventana * desp(d)); % Same delay for any method.
                [index_tr_cl, index_tr_op] = featuresNoDeslizantes(xtr_cl, xtr_op,fs, t_ventana, met);

                % Obtain outliers.
                out_cl = isoutlier(index_tr_cl);
                out_op = isoutlier(index_tr_op);

                % Obtain threshold 
                th = (max(index_tr_cl(~out_cl)) + min(index_tr_op(~out_op)))/2;
                threshold(met,s,k,d) = th;

%                 % Training data LDA without.
                tr_cl = index_tr_cl(~out_cl,:);
                tr_op = index_tr_op(~out_op,:);
                xtr_no = [tr_cl; tr_op]; % Data
                ytr_no = [zeros(size(tr_cl,1),1); ones(size(tr_op,1),1)]; % Labels

%                 % Entrenamos el LDA.
                lda_mdl = fitcdiscr(xtr_no, ytr_no);
%             
% 
%             %% TEST
%             
%                 %%% DESLIZANTE %%%
% 
%                 % Obtenemos los indices para los datos de test.
                [index_test_cl, index_test_op] = featuresNoDeslizantes(xtest_cl, xtest_op,fs, t_ventana, met);


%                 % Test data.
                xtest = [index_test_cl; index_test_op]; % Data
                ytest = [zeros(size(index_test_cl,1),1); ones(size(index_test_op,1),1)]; % Labels
% 
% 
%                 % Precision por estados - TH.
                pred_cl = index_test_cl <=th;
                pred_op = index_test_op > th;
%                 
                missclassified_cl = sum(pred_cl(2:end)~=1);
                acc_samp_cl(s,k,d) = 100*(1-(missclassified_cl*tam_ventana*fs*desp(d) + ((pred_cl(1)~=1)*fs*tam_ventana))./(size(xtest_cl,1)));
                
                missclassified_op = sum(pred_op(2:end)~=1);
                acc_samp_op(s,k,d) = 100*(1-(missclassified_op*tam_ventana*fs*desp(d)+ ((pred_op(1)~=1)*fs*tam_ventana))./(size(xtest_op,1)));
                
                
%                 % Precision por estados - LDA.
                pred_lda_cl = predict(lda_mdl, index_test_cl);
                pred_lda_op =  predict(lda_mdl, index_test_op);
                
                missclassified_cl = sum(pred_lda_cl(2:end)~=0);
                acc_lda_cl(s,k,d) = 100*(1-(missclassified_cl*tam_ventana*fs*desp(d) + ((pred_lda_cl(1)~=0)*fs*tam_ventana))./(size(xtest_cl,1)));
                missclassified_op = sum(pred_lda_op(2:end)~=1);
                acc_lda_op(s,k,d) = 100*(1-(missclassified_op*tam_ventana*fs*desp(d)+ ((pred_lda_op(1)~=1)*fs*tam_ventana))./(size(xtest_op,1)));
                

%                 % Corrreccion TH.
                [aux_cl, aux_op] = stateChangeCorrection(pred_cl, pred_op, vent_correc);

                missclassified_cl = sum(aux_cl(2:end)~=1);
                acc_cl_mod(s,k,d) = 100*(1-(missclassified_cl*tam_ventana*fs*desp(d) + ((aux_cl(1)~=1)*fs*tam_ventana))./(size(xtest_cl,1)));
                missclassified_op = sum(aux_op(2:end)~=1);
                acc_op_mod(s,k,d) = 100*(1-(missclassified_op*tam_ventana*fs*desp(d)+ ((aux_op(1)~=1)*fs*tam_ventana))./(size(xtest_op,1)));

%                 % Correccion LDA.
                [aux_cl, aux_op] = stateChangeCorrection(pred_lda_cl, pred_lda_op, vent_correc);

                missclassified_cl = sum(aux_cl(2:end)~=0);
                acc_lda_cl_mod(s,k,d) = 100*(1-(missclassified_cl*tam_ventana*fs*desp(d) + ((aux_cl(1)~=0)*fs*tam_ventana))./(size(xtest_cl,1)));
                missclassified_op = sum(aux_op(2:end)~=1);
                acc_lda_op_mod(s,k,d) = 100*(1-(missclassified_op*tam_ventana*fs*desp(d)+ ((aux_op(1)~=1)*fs*tam_ventana))./(size(xtest_op,1)));


            end
        end
    end
end

% Acc por muestras - TH
med_samp_cl = squeeze(mean(acc_samp_cl,2));
med_samp_op = squeeze(mean(acc_samp_op,2));

% Acc por muestras - LDA
med_lda_cl = squeeze(mean(acc_lda_cl,2));
med_lda_op = squeeze(mean(acc_lda_op,2));

% Acc modificados - TH
med_samp_mod_cl = squeeze(mean(acc_cl_mod,2));
med_samp_mod_op = squeeze(mean(acc_op_mod,2));

% Acc modificados - LDA
med_lda_mod_cl = squeeze(mean(acc_lda_cl_mod,2));
med_lda_mod_op = squeeze(mean(acc_lda_op_mod,2));


if plot_perf

    simbolos = {'r-o', 'g--+', 'b-.s', 'c-^', 'm:d', 'y-x', 'k--p', 'r:*', 'b-.h'};
    
    %Overlap
    xl_over = (1-desp)*100;
    figure(1);
    for s= 1:length(sujeto)
        subplot(4,2,s);
        plot(fliplr(med_samp_op(s,:)), simbolos{1}, 'LineWidth', 1.5, 'MarkerSize', 10); hold on;
        plot(fliplr(med_samp_mod_op(s,:)), simbolos{2}, 'LineWidth', 1.5, 'MarkerSize', 10); hold on;
        plot(fliplr(med_lda_op(s,:)), simbolos{4}, 'LineWidth', 1.5, 'MarkerSize', 10); hold on;
        plot(fliplr(med_lda_mod_op(s,:)), simbolos{5}, 'LineWidth', 1.5, 'MarkerSize', 10); hold on;
        title(['Subject ' num2str(s)]);
        ylim([50 100]);
        lgn = legend('TH', 'TH-Corr', 'LDA', 'LDA-Corr');
        set(gca, 'xtick', 1:4, 'xticklabels', fliplr(xl_over), 'xlim', [1,4], 'FontSize', 14, 'FontName', 'Times');
        ylabel('Accuracy (%)', 'FontSize', 16);
        
        if (s == length(sujeto))
            xlabel('Overlap (%)');
        end

        grid on;
    end
    suptitle('Open eyes');
    
    figure(2);
    for s= 1:length(sujeto)
        subplot(4,2,s);
        plot(fliplr(med_samp_cl(s,:)), simbolos{1}, 'LineWidth', 1.5, 'MarkerSize', 10); hold on;
        plot(fliplr(med_samp_mod_cl(s,:)), simbolos{2}, 'LineWidth', 1.5, 'MarkerSize', 10); hold on;
        plot(fliplr(med_lda_cl(s,:)), simbolos{4}, 'LineWidth', 1.5, 'MarkerSize', 10); hold on;
        plot(fliplr(med_lda_mod_cl(s,:)), simbolos{5}, 'LineWidth', 1.5, 'MarkerSize', 10); hold on;
        title(['Subject ' num2str(s)]);
        ylim([50 100]);
        lgn = legend('TH', 'TH-Corr', 'LDA', 'LDA-Corr');
        set(gca, 'xtick', 1:4, 'xticklabels', fliplr(xl_over), 'xlim', [1,4], 'FontSize', 14, 'FontName', 'Times');
        ylabel('Accuracy (%)', 'FontSize', 16);
        
        if (s == length(sujeto))
            xlabel('Overlap (%)');
        end

        grid on;
    end
    suptitle('Closed eyes');
    
end