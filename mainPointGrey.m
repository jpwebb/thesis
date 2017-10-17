%% Calibrate Point Grey RGB cameras

default_square_size = 36; % mm

% Grab Point Grey info from csv file
generatePointGreyInfoFile();

if ~exist('PointGreyInfo', 'var')
    return;
end

% Initialise with no devices selected for calibration
devices = 0;

while ~devices
    devices = getDevices(PointGreyInfo);
end

square_size = getSquareSize(default_square_size);

serial = zeros(length(devices));
cameraParams = [];
h = waitbar(0, 'Please Wait...');

if exist('PointGreyParams.mat', 'file') == 2
    load('PointGreyParams.mat');
else
    PointGreyParams = struct('deviceID', [], 'deviceSerialNumber', [],...
        'channel', [], 'intrinsicParams', [], ...
        'deviceParams', [], 'calibrationDate', [], 'calibrationTime', []);
end

local_idx = 1;

for i = 1 : length(PointGreyInfo)
    PointGreyParams(local_idx).deviceID = PointGreyInfo(i).ID;
    PointGreyParams(local_idx).deviceSerialNumber = PointGreyInfo(i).Serial;
    PointGreyParams(local_idx).channel = 'RGB';
    local_idx = local_idx + 1;
end

for i = 1:length(devices)
    
    id = devices(i);
    idx = find([PointGreyParams.deviceID] == id);
    serial = PointGreyParams(idx).deviceSerialNumber;
    im_folder = strcat('Point_Grey_', serial, filesep);
    cameraParams = calibrate(default_square_size, id, serial, im_folder);
    
    cur_date = datestr(datetime('now'), 'dd-mm-yyyy');
    cur_time = datestr(datetime('now'), 'HH:MM:SS');
    
    PointGreyParams(idx).intrinsicParams = struct('fx', [], 'fy', [], 'cx', [], 'cy', [], 's', []);
    PointGreyParams(idx).intrinsicParams.fx = cameraParams.IntrinsicMatrix(1, 1);
    PointGreyParams(idx).intrinsicParams.fy = cameraParams.IntrinsicMatrix(2, 2);
    PointGreyParams(idx).intrinsicParams.cx = cameraParams.IntrinsicMatrix(3, 1);
    PointGreyParams(idx).intrinsicParams.cy = cameraParams.IntrinsicMatrix(3, 2);
    PointGreyParams(idx).intrinsicParams.s  = cameraParams.IntrinsicMatrix(2, 1);
    PointGreyParams(idx).deviceParams = cameraParams;
    PointGreyParams(idx).calibrationDate = cur_date;
    PointGreyParams(idx).calibrationTime = cur_time;
    
    waitbar(i/length(devices), h, sprintf(['Calibrated ', num2str(i),...
        '/', num2str(length(devices)), ' device(s)']));
end

delete(h);

save('PointGreyParams', 'PointGreyParams');

%% Ask if the user wants to calibrate another device

% Get the standard font size
UIControl_FontSize_backup = get(0,'DefaultUIControlFontSize');

% Replace this with a larger font for easier readability
set(0, 'DefaultUIControlFontSize', 14);

% Get user input
user_choice = menu('Would you like to calibrate another Point Grey device?',...
    'Yes', 'No');

if user_choice == 1
    close all;
    mainPointGrey();
end