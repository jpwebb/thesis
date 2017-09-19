close all; clear; clc;

fprintf('Welcome to the Calibration tool.\n\n');

% Get the standard font size
UIControl_FontSize_backup = get(0,'DefaultUIControlFontSize');

% Replace this with a larger font for easier readability
set(0, 'DefaultUIControlFontSize', 14);

% Get user input
user_choice = menu('Select the device type for calibration:',...
    'Kinect','Point Grey');

% Replace the default font size
set(0, 'DefaultUIControlFontSize', UIControl_FontSize_backup);

% Call the Kinect calibration tool or the Point Grey calibration tool,
% depending on the user input
if user_choice == 1
    mainKinect();
elseif user_choice == 2
    mainPointGrey();
else
    fprintf('Error! No selection main, program exiting.\n\n');
    return;
end
