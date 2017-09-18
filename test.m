clc;

if exist('KinectParams.mat', 'file') == 2
    load('KinectParams.mat');
else
    fprintf('No calibration data found.\n');
    return;
end

example_id = [];

while isempty(example_id)
    try
        example_id = input('View intrinsic parameters by device ID. Enter ID: ', 's');
    catch
        warning('Invalid entry detected.');
    end
    example_id = str2double(string(example_id));
    if isnan(example_id)
        idx = -1;
    else
        idx = find([KinectParams.deviceID] == example_id);
    end
    if isempty(idx)
        fprintf(['Error: No data found for device ID ', num2str(example_id), '\n\n']);
        example_id = [];
    elseif idx == -1
        fprintf('Invalid entry detected, please try again.\n\n');
        example_id = [];
    end
end

% dev_ser = KinectParams(idx).deviceSerialNumber;

fprintf(['\nIntrinsic parameters for device #', num2str(example_id), ' (serial number: ', dev_ser, ')\n']);

fx = KinectParams(idx).deviceParams.IntrinsicMatrix(1, 1);
fy = KinectParams(idx).deviceParams.IntrinsicMatrix(2, 2);
cx = KinectParams(idx).deviceParams.IntrinsicMatrix(3, 1);
cy = KinectParams(idx).deviceParams.IntrinsicMatrix(3, 2);

fprintf(['fx: ', num2str(fx), '\nfy: ', num2str(fy), ...
    '\ncx: ', num2str(cx), '\ncy: ', num2str(cy), '\n']);
