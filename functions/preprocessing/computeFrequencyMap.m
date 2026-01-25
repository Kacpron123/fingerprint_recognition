function freq_map = computeFrequencyMap(I_norm, mask, orient_map, block_size, minWaveLength, maxWaveLength)
    [nRows, nCols] = size(I_norm);      
    H = floor(nRows / block_size);
    L = floor(nCols / block_size);
    
    freq_map_block = zeros(H, L);
    mask_block = imresize(double(mask), [H, L], 'nearest') > 0.5;
    if size(orient_map, 1) ~= nRows || size(orient_map, 2) ~= nCols
         orient_map = imresize(orient_map, [nRows, nCols], 'nearest');
    end
    for bi = 1:H
        for bj = 1:L
            if mask_block(bi, bj)
                rStart = (bi - 1) * block_size + 1;
                cStart = (bj - 1) * block_size + 1;
    
                rEnd = min(rStart + block_size - 1, nRows);
                cEnd = min(cStart + block_size - 1, nCols);
                

                
                block_orient = orient_map(rStart:rEnd, cStart:cEnd);
                
                sin_avg = mean(sin(2*block_orient(:)));
                cos_avg = mean(cos(2*block_orient(:)));
                dir_rad = 0.5 * atan2(sin_avg, cos_avg);
                
                block = I_norm(rStart : rEnd, cStart : cEnd);
                
                freq_val = computeBlockFrequency(block, dir_rad + pi/2, minWaveLength, maxWaveLength);
                freq_map_block(bi, bj) = freq_val;
            end
        end
    end
    valid_vals = freq_map_block(freq_map_block > 0);
    if ~isempty(valid_vals)
        global_median = median(valid_vals);
        holes = (freq_map_block == 0) & mask_block;
        freq_map_block(holes) = global_median;
    end

    freq_map_block = freq_map_block .* double(mask_block);
    msk = fspecial('gaussian', 7, 1.5);
    freq_smooth = imfilter(freq_map_block, msk, 'same');
    
    freq_map = imresize(freq_smooth, [nRows, nCols], 'bilinear');
    
    if size(mask, 1) ~= nRows || size(mask, 2) ~= nCols
        mask_resized = imresize(double(mask), [nRows, nCols], 'nearest');
    else
        mask_resized = double(mask);
    end
    
    freq_map = freq_map .* mask_resized;
end

function freq = computeBlockFrequency(block, dir_rad, minWL, maxWL)
    rotated_block = imrotate(block, rad2deg(dir_rad), 'bilinear', 'crop');
    
    block_size = size(block,1);
    cropsze = floor(block_size/sqrt(2));
    offset = floor((block_size-cropsze)/2);
    if offset < 1, offset = 1; end
    idx_end = offset+cropsze;
    if idx_end > size(rotated_block, 1), idx_end = size(rotated_block, 1); end
    
    rotated_block = rotated_block(offset:idx_end, offset:idx_end);
    V = sum(rotated_block, 2);
    V = V - mean(V);
    
    if all(V == 0)
        freq = 0;
        return;
    end
    
    ac = xcorr(V, 'coeff'); 
    center_idx = ceil(length(ac)/2);
    ac = ac(center_idx:end);
    
    [pks, locs] = findpeaks(ac);
    freq = 0;
    
    if ~isempty(locs)
        valid_peak_idx = find(locs > minWL, 1);
        
        if ~isempty(valid_peak_idx)
            peak_loc = locs(valid_peak_idx);
            waveLength = peak_loc - 1;
            
            if waveLength >= minWL && waveLength <= maxWL
                freq = 1 / waveLength;
            end
        end
    end
    
    if freq == 0
         zero_crossings = sum(abs(diff(V > 0)));
         if zero_crossings > 1
             avg_waveLength = (length(V) * 2) / zero_crossings;
             if avg_waveLength >= minWL && avg_waveLength <= maxWL
                 freq = 1 / avg_waveLength;
             end
         end
    end
end