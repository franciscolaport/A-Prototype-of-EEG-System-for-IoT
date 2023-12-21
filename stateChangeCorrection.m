function [pred_cl, pred_op] = stateChangeCorrection(pred_cl, pred_op, vent_correc)
    
    estado_cl = pred_cl(1);
    estado_op = pred_op(1);

    for sm = 2:size(pred_cl,1)-1
        if pred_cl(sm) ~= estado_cl
            if size(pred_cl,1) - sm >= vent_correc
                vc = find(pred_cl(sm+1:sm+vent_correc) == pred_cl(sm));
                long =  vent_correc;
            else
                long = size(pred_cl,1) - sm;
                vc = find(pred_cl(sm+1:sm+long) == pred_cl(sm));
            end
            
            if length(vc) == long
                estado_cl = pred_cl(sm);
            else
                pred_cl(sm) = estado_cl;
            end
        end

        if pred_op(sm) ~= estado_op
            if size(pred_op,1) - sm >= vent_correc
                vc = find(pred_op(sm+1:sm+vent_correc) == pred_op(sm));
                long =  vent_correc;
            else
                long = size(pred_op,1) - sm;
                vc = find(pred_op(sm+1:sm+long) == pred_op(sm));
            end
            
            if length(vc) == long
                estado_op = pred_op(sm);
            else
                pred_op(sm) = estado_op;
            end
        end
    end
end