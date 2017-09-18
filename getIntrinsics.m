% This script prints intrinsic coefficients for the user based on device ID
% number. The user is prompted to enter the ID number for the device they
% want to read data from, and provided a list of available devices.

close all; clear; %clc;

% Throw an error message if no data is found
if exist('KinectParams.mat', 'file') == 2
    load('KinectParams.mat');
else
    fprintf('No calibration data found.\n');
    return;
end

% Initialise a list of IDs for devices that have calibration data available
% for reading, as well as a count of such devices
id_list = zeros(length(KinectParams), 1);
id_count = 0;

% Only add IDs with calibration data
for i = 1:length(KinectParams)
    if ~isempty(KinectParams(i).deviceParams)
        id_count = id_count + 1;
        id_list(id_count) = KinectParams(i).deviceID;
    end
end

% Format the ID list so it's sorted numerically and nicely displayed
id_list = id_list(id_list ~= 0);
id_list = sort(id_list);
id_list = sprintf('%.0f, ' , id_list);
id_list = id_list(1:end-2);

% Initialise the user-specified ID
id = [];

% Parse user input until valid
while isempty(id)
    try
        fprintf('View intrinsic parameters by device ID.\n');
        id = input(['Enter ID (data available for ID ', id_list, '): '], 's');
    catch
        warning('Error! Invalid entry detected.');
    end
    id = str2double(string(id));
    if isnan(id)
        idx = -1;
    else
        idx = find([KinectParams.deviceID] == id);
    end
    if idx == -1
        fprintf('Invalid entry detected, please try again.\n\n');
        id = [];
    elseif isempty(idx) || isempty(KinectParams(idx).deviceParams)
        fprintf(['Error! No data found for device ID ', num2str(id), '\n\n']);
        id = [];    
    end
end

% Grab the serial number for the device
dev_ser = KinectParams(idx).deviceSerialNumber;

% Display the heading
fprintf(['\nIntrinsic parameters for device with ID ', num2str(id),...
    ' (serial number: ', dev_ser, ')\n']);

% Obtain the data for the chosen device
fx = KinectParams(idx).deviceParams.IntrinsicMatrix(1, 1);
fy = KinectParams(idx).deviceParams.IntrinsicMatrix(2, 2);
cx = KinectParams(idx).deviceParams.IntrinsicMatrix(3, 1);
cy = KinectParams(idx).deviceParams.IntrinsicMatrix(3, 2);

% Display the intrinsic parameters for the chosen device
fprintf(['fx: ', num2str(fx), '\nfy: ', num2str(fy), ...
    '\ncx: ', num2str(cx), '\ncy: ', num2str(cy), '\n']);

% Initialise what happens next
next_step = [];

% Parse user input until valid, then call the program to run again or exit
while isempty(next_step)
    next_step = lower(input('\nWould you like to view the intrinsics from another device?\nEnter ''y'' or ''n'': ', 's'));
    if strcmp(next_step, 'y')
        getIntrinsics;
    elseif strcmp(next_step, 'n')
        return;
    else
        fprintf('\nError! Invalid Input. Please try again.\n');
        next_step = [];
    end
end