% This script prompts the user to select their desired calibration type,
% whereby the options are 'r' (RGB) or 'd' (Depth). The script will
% continue to run until a valid respone is entered by the user.

function calibration_type = getCalibrationType()

% Initialise the type as empty
calibration_type = [];

% Only an input of either 'r' or 'd' is valid. There is no warning or
% invalid input message if the input is not correct. It should be straight
% forward enough for the user to realise they have made a mistake if their
% input is not accepted
while strcmp(calibration_type, 'r') + strcmp(calibration_type, 'd') == 0
    calibration_type = input('Enter the type of calibration to perform (enter ''r'' for RGB or ''d'' for Depth): ', 's');
end

% Convert the simple type to a longer string (to match the folder naming
% convention that has the stored image data)
switch calibration_type
    case 'r'
        calibration_type = 'RGB';
    case 'd'
        calibration_type = 'D';
end

end