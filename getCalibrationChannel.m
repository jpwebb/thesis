% This script prompts the user to select their desired calibration channel,
% where the options are 'r' (RGB) or 'd' (Depth). The script will continue
% to run until a valid respone is entered by the user.

function calibration_channel = getCalibrationChannel()

% Initialise the type as empty
calibration_channel = [];

% Only an input of either 'r' or 'd' is valid. There is no warning or
% invalid input message if the input is not correct. It should be straight
% forward enough for the user to realise they have made a mistake if their
% input is not accepted
while strcmp(calibration_channel, 'r') + strcmp(calibration_channel, 'd') == 0
    calibration_channel = input('Enter the type of calibration to perform (enter ''r'' for RGB or ''d'' for Depth): ', 's');
end

% Convert the simple type to a longer string (to match the folder naming
% convention that has the stored image data)
switch calibration_channel
    case 'r'
        calibration_channel = 'RGB';
    case 'd'
        calibration_channel = 'D';
end

fprintf('\n');

end