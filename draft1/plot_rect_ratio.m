clear;clc;addpath('../src');


p_min = 1;
p_max = 10;
q_min = 1;
q_max = 10;
pq_step = 1e-1;
num_ps = ceil((p_max - p_min) / pq_step);
num_qs = ceil((q_max - q_min) / pq_step);
result = nan(num_ps + 1, num_qs + 1);



% Case 1: p > q
p_idx = 0;
q_idx = 0;
progress = 0;
total_progress = num_ps * num_qs;
ps = p_min:pq_step:p_max;
qs = q_min:pq_step:q_max;

for p = p_min:pq_step:p_max
    p_idx = p_idx + 1;
    q_idx = 0
    for q = q_min:pq_step:q_max
        q_idx = q_idx + 1;
        progress = progress + 1.0/total_progress
        if p > q

            % Compute loss

            loss_params = struct( ...
                'unorm_ord',    mat2str(q), ...
                'udnorm_ord',   mat2str(p) ...
            );

            w_start = 1e-3;
            w_step = 1e-3;
            w_end = 1 + 2 * w_step;

            num_ws = floor((w_end - w_start) / w_step);
            losses = nan(1, num_ws + 1);
            ws = nan(1, num_ws + 1);

            w_idx = 1;
            for w = w_start:w_step:w_end
                losses(w_idx) = rect_true_loss(w, loss_params);
                ws(w_idx) = w;
                w_idx = w_idx + 1;
            end

            ws = ws(1:num_ws);
            losses = losses(1, 1:num_ws);

            [loss, idx] = min(losses);
            result(p_idx, q_idx) = ws(idx);

        end
    end
end