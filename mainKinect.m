%% Calibrate Kinect device(s)

default_square_size = 36; % mm
square_size = getSquareSize(default_square_size);

% Grab Kinect info from csv file
generateKinectInfoFile();

% Initialise with no devices selected for calibration
devices = 0;

while ~devices
    devices = getDevices(KinectInfo);
end

calibration_type = [];

while isempty(calibration_type)
    calibration_type = getCalibrationType();
end

serial = zeros(length(devices));
cameraParams = [];
h = waitbar(0, 'Please Wait...');

if exist('KinectParams.mat', 'file') == 2
    load('KinectParams.mat');
else
    KinectParams = struct('deviceID', [], 'deviceSerialNumber', [],...
        'deviceParams', [], 'calibrationDate', [], 'calibrationTime', []);
end

for i = 1:length(KinectInfo)
    KinectParams(i).deviceID = KinectInfo(i).ID;
    KinectParams(i).deviceSerialNumber = KinectInfo(i).Serial;
end

for i = 1:length(devices)
    
    id = devices(i);
    idx = find([KinectInfo.ID] == id);
    serial = KinectInfo(idx).Serial;
    im_folder = strcat('Kinect_', serial, filesep, calibration_type, filesep);
    cameraParams = calibrate(36, id, serial, im_folder);
    
    cur_date = datestr(datetime('now'), 'dd-mm-yyyy');
    cur_time = datestr(datetime('now'), 'HH:MM:SS');
    
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