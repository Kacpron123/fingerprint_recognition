function [term_clean, bif_clean] = removeFalseMinutiae(terminations, bifurcations, D)
    keep_t = true(size(terminations, 1), 1);
    keep_b = true(size(bifurcations, 1), 1);
    
    for i = 1:size(terminations, 1)
        for j = 1:size(bifurcations, 1)
            dist = sqrt(sum((terminations(i,:) - bifurcations(j,:)).^2));
            if dist < D
                keep_t(i) = false;
                keep_b(j) = false;
            end
        end
    end
    
    term_clean = terminations(keep_t, :);
    bif_clean = bifurcations(keep_b, :);

    keep_t2 = true(size(term_clean, 1), 1);
    for i = 1:size(term_clean, 1)
        for j = i+1:size(term_clean, 1)
            dist = sqrt(sum((term_clean(i,:) - term_clean(j,:)).^2));
            if dist < D
                keep_t2(i) = false;
                keep_t2(j) = false;
            end
        end
    end
    term_clean = term_clean(keep_t2, :);
end