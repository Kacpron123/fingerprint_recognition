function score = matchMinutiae(sig1, sig2)
    T_d = 5;      
    T_alpha = 0.3; 
    T_beta = 0.3;  

    n1 = length(sig1);
    n2 = length(sig2);
    matched_count = 0;

    if n1 == 0 || n2 == 0
        score = 0;
        return;
    end


    for i = 1:n1
        best_local_sim = 0;
        for j = 1:n2
            local_matches = 0;
            K = size(sig1(i).neighbors, 1);

            for k1 = 1:K
                v1 = sig1(i).neighbors(k1, :);
                for k2 = 1:size(sig2(j).neighbors, 1)
                    v2 = sig2(j).neighbors(k2, :);

                    cond_d = abs(v1(1) - v2(1)) < T_d;
                    cond_alpha = abs(v1(2) - v2(2)) < T_alpha;
                    cond_beta = abs(v1(3) - v2(3)) < T_beta;
                    cond_type = (v1(4) == v2(4));

                    if cond_d && cond_alpha && cond_beta && cond_type
                        local_matches = local_matches + 1;
                        break;
                    end
                end
            end

            sim = local_matches / K;
            if sim > best_local_sim
                best_local_sim = sim;
            end
        end

        if best_local_sim > 0.6
            matched_count = matched_count + 1;
        end
    end

    score = (matched_count / max(n1, n2)) * 100;
end