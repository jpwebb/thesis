close all; clear; clc;

im = imread('/Users/jasonwebb/Pictures/harbour.jpg');

nrows = size(im, 1);
ncols = size(im, 2);

num_horz_segs = 2;
num_vert_segs = 2;

im2 = im(1:nrows/num_vert_segs, 1:ncols/num_horz_segs, :);
im3 = im(1:nrows/num_vert_segs, ncols/num_horz_segs:2*ncols/num_horz_segs, :);
im4 = im(nrows/num_vert_segs:2*nrows/num_vert_segs, 1:ncols/num_horz_segs, :);
im5 = im(nrows/num_vert_segs:2*nrows/num_vert_segs, ncols/num_horz_segs:2*ncols/num_horz_segs, :);
im6 = [im2, im3; im4, im5];

figure, imshowpair(im, im6, 'montage');

im_tl = im(1:2*nrows/3, 1:2*ncols/3, :);
im_tr = im(1:2*nrows/3, 1*ncols/3:end, :);
im_bl = im(1*nrows/3:end, 1:2*ncols/3, :);
im_br = im(1*nrows/3:end, 1*ncols/3:end, :);
im_comb = [im_tl, im_tr; im_bl, im_br];
figure, imshow(im_comb);

im2distort = im_tl;
[r, c, d] = size(im2distort);       % Get the image dimensions
nPad = round((c-r)/2);                   % The number of padding rows
im2distort = cat(1, ones(nPad, c, 3), im2distort, ones(nPad, c, 3));  % Pad with white
options = [c c 3];  % An array containing the columns, rows, and exponent
tf = maketform('custom', 2, 2, [], ...  % Make the transformation structure
    @fisheye_inverse, options);
im_tld = imtransform(im2distort, tf);   % Transform the image

im2distort = im_tr;
[r, c, d] = size(im2distort);       % Get the image dimensions
nPad = round((c-r)/2);                   % The number of padding rows
im2distort = cat(1, ones(nPad, c, 3), im2distort, ones(nPad, c, 3));  % Pad with white
options = [c c 3];  % An array containing the columns, rows, and exponent
tf = maketform('custom', 2, 2, [], ...  % Make the transformation structure
    @fisheye_inverse, options);
im_trd = imtransform(im2distort, tf);   % Transform the image
im_trd = im_trd(1:end-1, 1:end-1, :);

im2distort = im_bl;
[r, c, d] = size(im2distort);       % Get the image dimensions
nPad = round((c-r)/2);                   % The number of padding rows
im2distort = cat(1, ones(nPad, c, 3), im2distort, ones(nPad, c, 3));  % Pad with white
options = [c c 3];  % An array containing the columns, rows, and exponent
tf = maketform('custom', 2, 2, [], ...  % Make the transformation structure
    @fisheye_inverse, options);
im_bld = imtransform(im2distort, tf);   % Transform the image

im2distort = im_br;
[r, c, d] = size(im2distort);       % Get the image dimensions
nPad = round((c-r)/2);                   % The number of padding rows
im2distort = cat(1, ones(nPad, c, 3), im2distort, ones(nPad, c, 3));  % Pad with white
options = [c c 3];  % An array containing the columns, rows, and exponent
tf = maketform('custom', 2, 2, [], ...  % Make the transformation structure
    @fisheye_inverse, options);
im_brd = imtransform(im2distort, tf);   % Transform the image
im_brd = im_brd(1:end-1, 1:end-1, :);



im_temp = [im_tld, im_trd; im_bld, im_brd];

figure, imshow(im_temp);                       % Display the image








function U = fisheye_inverse(X, T)

imageSize = T.tdata(1:2);
exponent = T.tdata(3);
origin = (imageSize+1)./2;
scale = imageSize./2;

x = (X(:, 1)-origin(1))/scale(1);
y = (X(:, 2)-origin(2))/scale(2);
R = sqrt(x.^2+y.^2);
theta = atan2(y, x);

cornerScale = min(abs(1./sin(theta)), abs(1./cos(theta)));
cornerScale(R < 1) = 1;
R = cornerScale.*R.^exponent;

x = scale(1).*R.*cos(theta)+origin(1);
y = scale(2).*R.*sin(theta)+origin(2);
U = [x y];

end