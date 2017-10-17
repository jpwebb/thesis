function [cx, cy, fx, fy] = initialGuess(device_folder)
f = dir(strcat(device_folder, '*.txt'));
fname = strcat(f.folder, filesep, f.name);
fid = fopen(fname);
text = fscanf(fid,'%f');
cx = text(1);
cy = text(2);
fx = text(3);
fy = text(4);

end