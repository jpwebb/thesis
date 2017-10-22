%% Calibrate Kinect RGB-D cameras

default_square_size = 90; % mm

% Grab Kinect info from csv file
generateKinectInfoFile();

if ~exist('KinectInfo', 'var')
    return;
end

% Initialise with no devices selected for calibration
devices = 0;

while ~devices
    devices = getDevices(KinectInfo);
end

calibration_channel = [];

while isempty(calibration_channel)
    calibration_channel = getCalibrationChannel();
end

square_size = getSquareSize(default_square_size);

serial = zeros(length(devices));
cameraParams = [];

h = waitbar(0, 'Please Wait...');

if exist('KinectParams.mat', 'file') == 2
    load('KinectParams.mat');
else    
    KinectParams = struct('deviceID', [], 'deviceSerialNumber', [],...
        'channel', [], 'intrinsicParams', [], ...
        'deviceParams', [], 'calibrationDate', [], 'calibrationTime', []);
end

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

for i = 1:length(devices)
    
    id = devices(i);
    idx = find([KinectParams.deviceID] == id & string({KinectParams.channel}) == calibration_channel);

    serial = KinectParams(idx).deviceSerialNumber;
    im_folder = strcat('Kinect_', serial, filesep, calibration_channel, filesep);
    
    images_found = checkForImages(im_folder);
    
    if ~images_found
        warning_msg = ['No ', calibration_channel, ' images found for device with ID ', num2str(id), '\n'];
        my_warning(warning_msg);
        continue;
    end
    
    cameraParams = calibrate(square_size, id, serial, im_folder);
    
    if isempty(cameraParams)
        continue;
    end
    
    cur_date = datestr(datetime('now'), 'dd-mm-yyyy');
    cur_time = datestr(datetime('now'), 'HH:MM:SS');
    
    KinectParams(idx).intrinsicParams = struct('fx', [], 'fy', [], 'cx', [], 'cy', [], 's', []);
    KinectParams(idx).intrinsicParams.fx = cameraParams.FocalLength(1);
    KinectParams(idx).intrinsicParams.fy = cameraParams.FocalLength(2);
    KinectParams(idx).intrinsicParams.cx = cameraParams.PrincipalPoint(1);
    KinectParams(idx).intrinsicParams.cy = cameraParams.PrincipalPoint(2);
    KinectParams(idx).intrinsicParams.s  = 0;
    KinectParams(idx).deviceParams = cameraParams;
    KinectParams(idx).calibrationDate = cur_date;
    KinectParams(idx).calibrationTime = cur_time;
    
    waitbar(i/length(devices), h, sprintf(['Calibrated ', num2str(i),...
        '/', num2str(length(devices)), ' device(s)']));
end

delete(h);

save('KinectParams', 'KinectParams');

% getIntrinsics

%% Ask if the user wants to calibrate another device

% Get the standard font size
UIControl_FontSize_backup = get(0,'DefaultUIControlFontSize');

% Replace this with a larger font for easier readability
set(0, 'DefaultUIControlFontSize', 14);

% Get user input
user_choice = menu('Would you like to calibrate another Kinect device?',...
    'Yes', 'No');

if user_choice == 1
    close all;
    mainKinect();
end