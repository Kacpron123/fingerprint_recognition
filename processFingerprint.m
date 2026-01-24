function [signatures, terms, bifs, mask] = processFingerprint(I_origin)
    I_origin = double(I_origin);
    if ndims(I_origin) == 3
        I_gray = rgb2gray(I_origin);
    else
        I_gray = I_origin;
    end
    I_gray = double(I_gray);


    block_size = 12;
    M0 = 128; V0 = 110;
    

    I_norm = normalizeImage(I_gray, M0, V0);
    

    added_blocks = 2;
    [nRows, nCols] = size(I_norm);
    pad_r = mod(-nRows, block_size);
    pad_c = mod(-nCols, block_size);
    I_norm = padarray(I_norm, [pad_r, pad_c], 128, 'post'); 
    I_norm = padarray(I_norm, [added_blocks*block_size, added_blocks*block_size], 128, 'both');

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


    [terms_raw, bifs_raw] = extractMinutiae(I_skel, mask);
    [terms, bifs] = removeFalseMinutiae(terms_raw, bifs_raw, 6);
    
    signatures = computeVectorSignatures(terms, bifs, theta_map, 3);
end