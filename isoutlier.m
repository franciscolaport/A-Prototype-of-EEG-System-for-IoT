function outliers = isoutlier(index)

    % Replicamos el metodo isoutlier de matblab 2019.
    % Utilizando scaled median absolute deviation.

%     mad = median(abs(index-median(index)));
%     c=-1/(sqrt(2)*erfcinv(3/2));
%     
%     th_sup = median(index) + 3*mad;
%     
%     th_inf = median(index) - 3*mad;
%     
%     outliers = index > th_sup | index < th_inf;

    m =  mean(index);
    d = std(index);
    th_sup = m + 3*d;
    th_inf = m - 1*d;
    
    outliers = index > th_sup;
end