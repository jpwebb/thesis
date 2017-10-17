function init_intrinsics = getInitIntrinsics(im_folder)

fid = fopen(strcat(im_folder, 'intrinsics.txt'));

init_intrinsics = [];

if fid ~= -1
    data = textscan(fid, '%s %f', 'delimiter', '\t', 'headerlines', 1);
    cx = data{2}(strcmpi(data{1}, 'cx'));
    cy = data{2}(strcmpi(data{1}, 'cy'));
    fx = data{2}(strcmpi(data{1}, 'fx'));
    fy = data{2}(strcmpi(data{1}, 'fy'));
    fclose(fid);
    if length([cx, cy, fx, fy]) == 4
        init_intrinsics = [fx, 0, 0; 0, fy, 0; cx, cy, 1];
    end
end

end