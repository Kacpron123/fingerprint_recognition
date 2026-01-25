function [new_terms, new_bifs] = removeFalseMinutiae(terms, bifs, K1, mask)
    % Eliminacja fałszywych minucji
    % K1 to średnia odległość między prążkami (standardowo 9) 

    % 1. Filtracja przez maskę (usuwa punkty brzegowe)
    % Sprawdzamy tylko punkty, które leżą wewnątrz ERADOWANEJ maski
    if ~isempty(terms)
        idx_t = diag(mask(terms(:,1), terms(:,2)));
        terms = terms(idx_t == 1, :);
    end
    if ~isempty(bifs)
        idx_b = diag(mask(bifs(:,1), bifs(:,2)));
        bifs = bifs(idx_b == 1, :);
    end

    valid_terms = true(size(terms, 1), 1);
    valid_bifs = true(size(bifs, 1), 1);
    
    % 2. Relacja Termination-Bifurcation (Usuwanie ostróg / Spurs)
    for i = 1:size(terms, 1)
        for j = 1:size(bifs, 1)
            if norm(terms(i,:) - bifs(j,:)) < K1
                valid_terms(i) = false;
                valid_bifs(j) = false;
            end
        end
    end

    % 3. Relacja Termination-Termination (Łączenie przerw / Broken Ridges)
    for i = 1:size(terms, 1)
        for j = i+1:size(terms, 1)
            if norm(terms(i,:) - terms(j,:)) < K1
                valid_terms(i) = false;
                valid_terms(j) = false;
            end
        end
    end

    % 4. Relacja Bifurcation-Bifurcation (Usuwanie mostków / Bridges)
    for i = 1:size(bifs, 1)
        for j = i+1:size(bifs, 1)
            if norm(bifs(i,:) - bifs(j,:)) < K1
                valid_bifs(i) = false;
                valid_bifs(j) = false;
            end
        end
    end

    new_terms = terms(valid_terms, :);
    new_bifs = bifs(valid_bifs, :);
end