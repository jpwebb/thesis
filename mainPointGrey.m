%% Calibrate Kinect device(s)

default_square_size = 36; % mm
square_size = getSquareSize(default_square_size);

% Grab Point Grey info from csv file
generatePointGreyInfoFile();

% Initialise with no devices selected for calibration
devices = 0;

while ~devices
    devices = getDevices(PointGreyInfo);
end

serial = zeros(length(devices));
cameraParams = [];
h = waitbar(0, 'Please Wait...');

if exist('PointGreyParams.mat', 'file') == 2
    load('PointGreyParams.mat');
else
    PointGreyParams = struct('deviceID', [], 'deviceSerialNumber', [],...
        'deviceParams', [], 'calibrationDate', [], 'calibrationTime', []);
end

for i = 1:length(PointGreyInfo)
    PointGreyParams(i).deviceID = PointGreyInfo(i).ID;
    PointGreyParams(i).deviceSerialNumber = PointGreyInfo(i).Serial;
end

for i = 1:length(devices)
    
    id = devices(i);
    idx = find([PointGreyInfo.ID] == id);
    serial = PointGreyInfo(idx).Serial;
    im_folder = strcat('Point_Grey_', serial, filesep);
    cameraParams = calibrate(36, id, serial, im_folder);
    
    cur_date = datestr(datetime('now'), 'dd-mm-yyyy');
    cur_time = datestr(datetime('now'), 'HH:MM:SS');
    
    PointGreyParams(idx).deviceParams = cameraParams;
    PointGreyParams(idx).calibrationDate = cur_date;
    PointGreyParams(idx).calibrationTime = cur_time;
    
    waitbar(i/length(devices), h, sprintf(['Calibrated ', num2str(i),...
        '/', num2str(length(devices)), ' device(s)']));
end

delete(h);

save('PointGreyParams', 'PointGreyParams');

% getIntrinsics

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