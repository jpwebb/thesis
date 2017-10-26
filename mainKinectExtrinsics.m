%% Calibrate Kinect RGB-D cameras (intrinsic parameters)

default_square_size = 90; % mm

% Grab Kinect info from text file
generateKinectInfoFile();

if ~exist('KinectInfo', 'var')
    return;
end

% Initialise with no devices selected for calibration
device = 0;

while ~device
    device = getDevice(KinectInfo);
end

calibration_channel = [];

while isempty(calibration_channel)
    calibration_channel = getCalibrationChannel();
end

square_size = getSquareSize(default_square_size);

serial1 = zeros(length(device));
stereoParams = [];

h = waitbar(0, 'Please Wait...');

if exist('KinectParams.mat', 'file') == 2
    load('KinectParams.mat');
    KinectParams = checkParams(KinectParams, KinectInfo);
else
    KinectParams = struct('deviceID', [], 'deviceSerialNumber', [],...
        'channel', [], 'intrinsicParams', [], 'extrinsicParams', []);
    
    local_idx = 1;
    
    for i = 1 : length(KinectInfo)
        KinectParams(local_idx).deviceID = KinectInfo(i).ID;
        KinectParams(local_idx + 1).deviceID = KinectInfo(i).ID;
        KinectParams(local_idx).deviceSerialNumber = KinectInfo(i).Serial;
        KinectParams(local_idx + 1).deviceSerialNumber = KinectInfo(i).Serial;
        KinectParams(local_idx).channel = 'RGB';
        KinectParams(local_idx + 1).channel = 'D';
        local_idx = local_idx + 2;
    end
end

id1 = device;
if id1 ~= 1
    id2 = id1 - 1;
else
    id2 = id1;
end

idx1 = find([KinectParams.deviceID] == id1 & string({KinectParams.channel}) == calibration_channel);
idx2 = find([KinectParams.deviceID] == id2 & string({KinectParams.channel}) == calibration_channel);

serial1 = KinectParams(idx1).deviceSerialNumber;
serial2 = KinectParams(idx2).deviceSerialNumber;

im_folder1 = strcat('Kinect_', serial1, filesep, calibration_channel, filesep);
im_folder2 = strcat('Kinect_', serial2, filesep, calibration_channel, filesep);

images_found = checkForImages(im_folder1);

if ~images_found
    warning_msg = ['No ', calibration_channel, ' images found for device with ID ', num2str(id1), '\n'];
    my_warning(warning_msg);
    return;
end

images_found = checkForImages(im_folder2);

if ~images_found
    error_msg = ['No ', calibration_channel, ' images found for device with ID ', num2str(id2), '.'];
    delete(h);
    my_error(error_msg);
    return;
end

cur_date = datestr(datetime('now'), 'dd-mm-yyyy');
cur_time = datestr(datetime('now'), 'HH:MM:SS');

stereoParams = calibrateExtrinsics(square_size, id1, serial1, im_folder1, id2, serial2, im_folder2);

if isempty(stereoParams)
    error_msg = 'Unable to compute extrinsic parameters.';
    delete(h);
    my_error(error_msg);
    return;
end

KinectParams(idx1).extrinsicParams = struct('local', []);
KinectParams(idx1).extrinsicParams.local = struct('R', [], 't', [], ...
    'all', [], 'calibrationDate', [], 'calibrationTime', []);
KinectParams(idx1).extrinsicParams.local.R = stereoParams.RotationOfCamera2;
KinectParams(idx1).extrinsicParams.local.t = stereoParams.TranslationOfCamera2;
KinectParams(idx1).extrinsicParams.local.all = stereoParams;
KinectParams(idx1).extrinsicParams.local.calibrationDate = cur_date;
KinectParams(idx1).extrinsicParams.local.calibrationTime = cur_time;

delete(h);

save('KinectParams', 'KinectParams');

%% Ask if the user wants to calibrate another device

% Get the standard font size
UIControl_FontSize_backup = get(0,'DefaultUIControlFontSize');

% Replace this with a larger font for easier readability
set(0, 'DefaultUIControlFontSize', 14);

% Get user input
user_choice = menu('Would you like to calibrate another Kinect pair?',...
    'Yes', 'No');

if user_choice == 1
    close all;
    mainKinectExtrinsics();
end
