clc;clear all;close all;
I_origin=imread("Dataset\102_6.tif");
I_origin=double(I_origin);

if ndims(I_origin)==3
    I_gray=rgb2gray(I_origin);
else
    I_gray=I_origin;
end
I_gray=double(I_gray);

block_size=12; % block size
% normalization
I_norm = normalizeImage(I_gray,128,110);
% segmentation
added_blocks=2;
[nRows,nCols]=size(I_norm);
pad_r = mod(-nRows, block_size);
pad_c = mod(-nCols, block_size);
I_norm = padarray(I_norm, [pad_r, pad_c], 128, 'post'); 
I_norm = padarray(I_norm, [added_blocks*block_size, added_blocks*block_size], 128, 'both');

[I_seg,mask] = segmentImage(I_norm,block_size,5);
% orientation
theta_map=computeOrientation(I_norm,block_size,1.2);
theta_map(~mask)=0;
% frequency
freq_map=computeFrequencyMap(I_seg,mask,theta_map,block_size,7,15);
% gabor filter
I_enhanced = gaborFilter(I_seg,theta_map,freq_map,mask,21,0.5,5.0);
%mask = imerode(mask, strel('disk', block_size));
I_enhanced(~mask)=1;

%binarization
I_binary=imbinarize(I_enhanced, 0.5);
%skeletization
I_skel = bwmorph(~I_binary, 'skel', Inf); 
I_skel = bwmorph(I_skel, 'spur', 5);
I_skel(~mask)=0;










% minutiae extraction
[terms, bifs] = extractMinutiae(I_skel, mask);

% post-processing
D = 6; % distance threshold
[terms_c, bifs_c] = removeFalseMinutiae(terms, bifs, D);


figure('Name','Minutiae Extraction','NumberTitle','off');
imshow(I_skel); hold on;
title('Extracted Minutiae (Red: Terminations, Blue: Bifurcations)');

if ~isempty(terms_c)
    plot(terms_c(:,2), terms_c(:,1), 'ro', 'MarkerSize', 5, 'LineWidth', 1);
end
if ~isempty(bifs_c)
    plot(bifs_c(:,2), bifs_c(:,1), 'bs', 'MarkerSize', 5, 'LineWidth', 1);
end
hold off;






% --------------------------
% Display all images in one figure
figure('Name','Fingerprint Processing Stages','NumberTitle','off');

subplot(2,2,1);
imshow(I_gray./255);
title('Grayscale');

subplot(2,2,2);
imshow(I_seg./255);
title('Segmented');


subplot(2,3,4); %theta
W = block_size;
[nRows,nCols]=size(I_seg);
rows_grid = round(W/2 : W : nRows);
cols_grid = round(W/2 : W : nCols);

[X_grid, Y_grid] = meshgrid(cols_grid, rows_grid);
theta_grid = theta_map(rows_grid, cols_grid); 

% background
imshow(I_seg, []); 
hold on;

len = W / 2;
theta_flat = theta_grid(:);
X_flat = X_grid(:);
Y_flat = Y_grid(:);

U_line = len * cos(theta_flat);
V_line = len * sin(theta_flat);

for k = 1:length(X_flat)
    r_idx = round(Y_flat(k));
    c_idx = round(X_flat(k));
    if r_idx > 0 && r_idx <= nRows && c_idx > 0 && c_idx <= nCols && mask(r_idx, c_idx)
        x_start = X_flat(k) - U_line(k);
        x_end   = X_flat(k) + U_line(k);
        y_start = Y_flat(k) - V_line(k);
        y_end   = Y_flat(k) + V_line(k);
        plot([x_start, x_end], [y_start, y_end], 'r-', 'LineWidth', 1);
    end
end

hold off;
title('Orientation Field (Lines)');

subplot(2,3,5);
imshow(freq_map,[]);
title('frequency');

subplot(2,3,6);
imshow(I_enhanced,[]);
title("gabor")

figure();
% ------------------------
subplot(1,3,1);
imshow(I_binary);
title('binary');

subplot(1,3,2);
imshow(I_skel);
title('skelet');
% ------------------------
