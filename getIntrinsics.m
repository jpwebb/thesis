close all; clear; clc;

if exist('KinectParams.mat', 'file') == 2
    load('KinectParams.mat');
else
    fprintf('No calibration data found.\n');
    return;
end

id_list = zeros(length(KinectParams), 1);
id_count = 0;
for i = 1:length(KinectParams)
    if ~isempty(KinectParams(i).deviceParams)
        id_count = id_count + 1;
        id_list(id_count) = KinectParams(i).deviceID;
    end
end

id_list = id_list(id_list ~= 0);
id_list = sort(id_list);
id_list = sprintf('%.0f, ' , id_list);
id_list = id_list(1:end-2);

example_id = [];

while isempty(example_id)
    try
        fprintf('View intrinsic parameters by device ID.\n');
        example_id = input(['Enter ID (data available for ID ', id_list, '): '], 's');
    catch
        warning('Error! Invalid entry detected.');
    end
    example_id = str2double(string(example_id));
    if isnan(example_id)
        idx = -1;
    else
        idx = find([KinectParams.deviceID] == example_id);
    end
    if idx == -1
        fprintf('Invalid entry detected, please try again.\n\n');
        example_id = [];
    elseif isempty(idx) || isempty(KinectParams(idx).deviceParams)
        fprintf(['Error! No data found for device ID ', num2str(example_id), '\n\n']);
        example_id = [];    
    end
end

dev_ser = KinectParams(idx).deviceSerialNumber;

fprintf(['\nIntrinsic parameters for device with ID ', num2str(example_id), ' (serial number: ', dev_ser, ')\n']);

fx = KinectParams(idx).deviceParams.IntrinsicMatrix(1, 1);
fy = KinectParams(idx).deviceParams.IntrinsicMatrix(2, 2);
cx = KinectParams(idx).deviceParams.IntrinsicMatrix(3, 1);
cy = KinectParams(idx).deviceParams.IntrinsicMatrix(3, 2);

fprintf(['fx: ', num2str(fx), '\nfy: ', num2str(fy), ...
    '\ncx: ', num2str(cx), '\ncy: ', num2str(cy), '\n']);

%%

user_response = [];

while isempty(user_response)
    user_response = lower(input('\nWould you like to view the intrinsics from another device?\nEnter ''y'' or ''n'': ', 's'));
    if strcmp(user_response, 'y')
        getIntrinsics;
    elseif strcmp(user_response, 'n')
        return;
    else
        fprintf('\nError! Invalid Input. Please try again.\n');
        user_response = [];
    end
end