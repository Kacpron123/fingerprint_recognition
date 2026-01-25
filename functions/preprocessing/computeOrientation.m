function theta_map = computeOrientation(I_seg, W, sigma)
    % Computes the pixel-wise orientation map of a fingerprint image.
    % Returns theta_map of size size(I_seg).
    
    I_seg = double(I_seg);
    [nRows, nCols] = size(I_seg);
    
    I_smooth = imgaussfilt(I_seg, 0.5); 
    [Gx, Gy] = imgradientxy(I_smooth, 'sobel');
    
    Gxx = Gx.^2;
    Gyy = Gy.^2;
    Gxy = Gx .* Gy;
    
    filter_sigma = W / 2; 
    k_size = 2 * ceil(3 * filter_sigma) + 1;
    h = fspecial('gaussian', k_size, filter_sigma);
    
    Gxx_smooth = imfilter(Gxx, h, 'symmetric');
    Gyy_smooth = imfilter(Gyy, h, 'symmetric');
    Gxy_smooth = imfilter(Gxy, h, 'symmetric');
    
    Vx = 2 * Gxy_smooth;
    Vy = Gxx_smooth - Gyy_smooth;
    
    theta = 0.5 * atan2(Vx, Vy + eps);
    
    Phi_x = cos(2 * theta);
    Phi_y = sin(2 * theta);
    
    msk_smooth = fspecial('gaussian', 2*ceil(3*sigma)+1, sigma);
    Phi_x_smooth = imfilter(Phi_x, msk_smooth, 'symmetric');
    Phi_y_smooth = imfilter(Phi_y, msk_smooth, 'symmetric');
    
    theta_map = 0.5 * atan2(Phi_y_smooth, Phi_x_smooth);
    theta_map = theta_map + pi/2;
end