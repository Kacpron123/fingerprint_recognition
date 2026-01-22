function signatures = computeVectorSignatures(terms, bifs, theta_map, K)
    all_minutiae = [];
    
    for i = 1:size(terms, 1)
        r = terms(i,1); c = terms(i,2);
        all_minutiae = [all_minutiae; r, c, 1, theta_map(r,c)];
    end
    for i = 1:size(bifs, 1)
        r = bifs(i,1); c = bifs(i,2);
        all_minutiae = [all_minutiae; r, c, 2, theta_map(r,c)];
    end

    num_m = size(all_minutiae, 1);
    signatures = struct('central_minutia', {}, 'neighbors', {});

    for i = 1:num_m
        mi = all_minutiae(i, :);
        distances = [];
        
        for j = 1:num_m
            if i == j, continue; end
            mj = all_minutiae(j, :);
            dist = sqrt((mi(1)-mj(1))^2 + (mi(2)-mj(2))^2);
            distances = [distances; j, dist];
        end
        
        if ~isempty(distances)
            distances = sortrows(distances, 2);
            num_neighbors = min(K, size(distances, 1));
            
            neighbor_data = [];
            for n = 1:num_neighbors
                idx_j = distances(n, 1);
                mj = all_minutiae(idx_j, :);
                
                d_ij = distances(n, 2);
                
                alpha_ij = mj(4) - mi(4);
                
                line_angle = atan2(mj(1) - mi(1), mj(2) - mi(2));
                beta_ij = line_angle - mi(4);
                
                alpha_ij = atan2(sin(alpha_ij), cos(alpha_ij));
                beta_ij = atan2(sin(beta_ij), cos(beta_ij));
                
                neighbor_data = [neighbor_data; d_ij, alpha_ij, beta_ij, mj(3)];
            end
            
            signatures(i).central_minutia = mi;
            signatures(i).neighbors = neighbor_data;
        end
    end
end