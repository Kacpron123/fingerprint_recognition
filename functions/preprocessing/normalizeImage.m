function I_norm = normalizeImage(I_gray, M0, V0)
    % This function normalizes a fingerprint image
    % I_gray - grayscale image (double or uint8)
    % M0, V0 - desired mean and variance
    ...
    
    if ~isa(I_gray,'double')
        I_gray = double(I_gray);
    end

    M=mean2(I_gray);
    V=var(I_gray(:));
    
    I_norm = double(I_gray);
    mask1 = I_norm> M;
    mask2 = I_norm<=M;
    I_norm(mask1)  = M0 + sqrt(V0*(M - I_norm(mask1)).^2 / V);
    I_norm(mask2) = M0 - sqrt(V0*(M - I_norm(mask2)).^2 / V);

end