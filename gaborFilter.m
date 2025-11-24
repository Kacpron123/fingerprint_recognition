function I_enhanced = gaborFilter(I_norm, orient_map, freq_map,mask,K,sigma_ratio,sigma_y_const)
% gaborFilter Applies a locally adaptive Gabor filter
    [nRows, nCols] = size(I_norm);       
    I_enhanced = I_norm; 
    
    halfK = floor(K / 2);


    [x, y] = meshgrid(-halfK : halfK, -halfK : halfK);
    
    % Resize maps to full image size
    mask_full = imresize(mask, [nRows, nCols], 'bilinear');
    orient_map_full = orient_map+pi/2;
    freq_map_full = imresize(freq_map, [nRows, nCols], 'bilinear');

    for r = halfK+1 : nRows - halfK
        for c = halfK+1 : nCols - halfK
            
            f = freq_map_full(r, c);
            area_mask = mask_full(r-halfK : r+halfK, c-halfK : c+halfK);

            if f > 0 && all(area_mask(:))
                orient_val = orient_map_full(r, c);
                
                wavelength = 1/f;
                sigma_x = sigma_ratio * wavelength;
                sigma_y = sigma_y_const;
                
                x_prime = x * cos(orient_val) + y * sin(orient_val);
                y_prime = -x * sin(orient_val) + y * cos(orient_val);

                G = exp(-((x_prime.^2)/(2*sigma_x^2) + (y_prime.^2)/(2*sigma_y^2))) .* cos(2*pi*f*x_prime);
                G = G - mean(G(:)); 
                
                area = I_norm(r-halfK : r+halfK, c-halfK : c+halfK);
                
                I_enhanced(r, c) = sum(sum(double(area) .* G));
            else
                I_enhanced(r, c) = 1;
            end
        end
    end
end