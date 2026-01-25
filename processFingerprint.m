function [signatures, terms, bifs, mask] = processFingerprint(I_origin)
    I_origin = double(I_origin);
    if ndims(I_origin) == 3
        I_gray = rgb2gray(I_origin);
    else
        I_gray = I_origin;
    end
    I_gray = double(I_gray);


    block_size = 16;
    M0 = 128; V0 = 110;
    

    I_norm = normalizeImage(I_gray, M0, V0);
    

    added_blocks = 2;
    [nRows, nCols] = size(I_norm);
    pad_r = mod(-nRows, block_size);
    pad_c = mod(-nCols, block_size);
    I_norm = padarray(I_norm, [pad_r, pad_c], 128, 'post'); 
    I_norm = padarray(I_norm, [added_blocks*block_size, added_blocks*block_size], 128, 'post');

    [I_seg, mask] = segmentImage(I_norm, block_size, 5);
    

    theta_map = computeOrientation(I_norm, block_size, 1.2);
    theta_map(~mask) = 0;

    freq_map = computeFrequencyMap(I_seg, mask, theta_map, block_size, 7, 15);
    

    I_enhanced = gaborFilter(I_seg, theta_map, freq_map, mask, 21, 0.5, 5.0);
    I_enhanced(~mask) = 1;


    I_binary = imbinarize(I_enhanced, 0.5);
    

    I_skel = bwmorph(~I_binary, 'skel', Inf); 
    I_skel = bwmorph(I_skel, 'spur', 5);
    I_skel(~mask)=0;

    % Przygotowanie maski (Erozja, aby pozbyć się punktów brzegowych)
    se = strel('disk', 22);            
    eroded_mask = imerode(mask, se);

    [terms_raw, bifs_raw] = extractMinutiae(I_skel, mask);
    [terms, bifs] = removeFalseMinutiae(terms_raw, bifs_raw, 9, eroded_mask);

    figure('Name', 'Before and after removing false minutiae', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 500]);

    subplot(1, 2, 1);
    imshow(I_skel); hold on;
    title(['Before  (All: ', num2str(size(terms_raw,1) + size(bifs_raw,1)), ')']);
    if ~isempty(terms_raw)
        plot(terms_raw(:,2), terms_raw(:,1), 'ro', 'MarkerSize', 4); 
    end
    if ~isempty(bifs_raw)
        plot(bifs_raw(:,2), bifs_raw(:,1), 'bs', 'MarkerSize', 4);
    end
    hold off;
    
    subplot(1, 2, 2);
    imshow(I_skel); hold on;
    title(['After (All: ', num2str(size(terms,1) + size(bifs,1)), ')']);
    if ~isempty(terms)
        plot(terms(:,2), terms(:,1), 'ro', 'MarkerSize', 5, 'LineWidth', 1);
    end
    if ~isempty(bifs)
        plot(bifs(:,2), bifs(:,1), 'bs', 'MarkerSize', 5, 'LineWidth', 1);
    end
    hold off;

    
    signatures = computeVectorSignatures(terms, bifs, theta_map, 3);
end