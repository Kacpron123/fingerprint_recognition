function [I_seg, mask] = segmentImage(I_norm, block_size, T)
    % This function performs block-based segmentation of a fingerprint image
    % I_norm - normalized grayscale image (double)
    % block_size - size of block
    % T - threshold for local variance
    %
    % Returns:
    % I_seg - segmented image, background set to 0
    ...
    [nRows, nCols] = size(I_norm);
    mask = false(nRows, nCols);

    for i = 1:block_size:nRows-block_size+1
        for j = 1:block_size:nCols-block_size+1
            block = I_norm(i:i+block_size-1, j:j+block_size-1);
            if var(double(block(:))) >= T*T
                mask(i:i+block_size-1, j:j+block_size-1) = true;
            end
        end
    end
    I_seg = I_norm;
    
    mask=imfill(mask,"holes");
    
    b=4*block_size;
    mask = imopen(mask, strel('square', b));
    I_seg(~mask)=0;
end
