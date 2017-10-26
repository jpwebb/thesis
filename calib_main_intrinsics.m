close all; clear; clc;

fprintf('Welcome to the Intrinsic Calibration tool.\n\n');

% Get the standard font size
UIControl_FontSize_backup = get(0, 'DefaultUIControlFontSize');

% Replace this with a larger font for easier readability
set(0, 'DefaultUIControlFontSize', 14);

% Get user input
user_choice = menu('Select the device type for calibration:',...
    'Kinect', 'Point Grey', 'Other');

% Call the Kinect calibration tool or the Point Grey calibration tool,
% depending on the user input
if user_choice == 1
    mainKinect();
elseif user_choice == 2
    mainPointGrey();
elseif user_choice == 3
    mainOther();
else
    msg = 'No selection made! Exiting program.';
    my_error(msg);
end

% Get user input after a calibration has been performed
user_choice_post = menu('Would you like to perform another intrinsic calibration?',...
    'Yes', 'No');

% Reset the default font size
set(0, 'DefaultUIControlFontSize', UIControl_FontSize_backup);

if user_choice_post == 1
    close all;
    calib_main_intrinsics();
end

return;