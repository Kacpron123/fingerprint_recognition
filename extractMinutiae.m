function [terminations, bifurcations] = extractMinutiae(I_skel, mask)
    [nRows, nCols] = size(I_skel);
    terminations = [];
    bifurcations = [];
    
    for i = 2:nRows-1
        for j = 2:nCols-1
            if I_skel(i,j) == 1 && mask(i,j)
                P = [I_skel(i,j+1) I_skel(i-1,j+1) I_skel(i-1,j) I_skel(i-1,j-1) ...
                     I_skel(i,j-1) I_skel(i+1,j-1) I_skel(i+1,j) I_skel(i+1,j+1)];
                P(9) = P(1);
                
                cn = 0.5 * sum(abs(diff(P)));
                
                if cn == 1
                    terminations = [terminations; i, j];
                elseif cn == 3
                    bifurcations = [bifurcations; i, j];
                end
            end
        end
    end
end