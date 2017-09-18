close all; clear; clc;

% Enter the size of each square on the target in real world units (mm)
square_size = 36;

% Grab Kinect info from csv file
generateKinectInfoFile();

% Initialise with no devices selected for calibration
devices = 0;


while ~devices
    devices = getDevices(KinectInfo);
end

cal_type = [];

while strcmp(cal_type, 'r') + strcmp(cal_type, 'd') == 0
    cal_type = input('Enter the type of calibration to perform (enter ''r'' for RGB or ''d'' for Depth): ', 's');
end

switch cal_type
    case 'r'
        cal_type = 'RGB';
    case 'd'
        cal_type = 'D';
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
    im_folder = strcat('Kinect_', serial, filesep, cal_type, filesep);
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

getIntrinsics