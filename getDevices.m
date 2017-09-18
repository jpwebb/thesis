% This script generates a list of devices to calibrate via user-selected
% inputs. The user enters ID numbers in the form of a single number (e.g.
% "1" returns "[1]"), a list of specific numbers (e.g. "1, 3" returns "[1, 
% 3]") or a list of continuous numbers (e.g. "1:3" returns "[1, 2, 3]").

function devices = getDevices(KinectInfo)

% Initialise an error flag
error_flag = 0;

% Find the minimum and maximum ID numbers that should be accepted.
min_device = min(cell2mat({KinectInfo.ID}'));
max_device = max(cell2mat({KinectInfo.ID}'));

% Generate a nice list of the device numbers (ordered and formatted)
device_list = cell2mat({KinectInfo.ID});
device_list = sort(device_list);
device_list = sprintf('%.0f, ' , device_list);
device_list = device_list(1:end-2);

% Prompt the user for their input and convert the string into a number
fprintf(['The following device IDs are available for calibration: ', device_list, '.\n']);
devices = input('Enter the device ID(s) to calibrate: ', 's');
devices = str2num(devices);

% Display various error messages and trigger the error flag if appropriate
if isempty(devices)
    fprintf('\nError! Invalid input. Please try again.\n\n');
    error_flag = 1;
elseif any(devices > max_device)
    fprintf('\nError! You entered a number that was too high. Please try again.\n\n');
    error_flag = 1;
elseif any(devices < min_device)
    fprintf('\nError! You entered a number that was too low. Please try again.\n\n');
    error_flag = 1;
elseif length(devices) > length(KinectInfo)
    fprintf('\nError! More devices chosen than data recorded. Please try again.\n\n');
    error_flag = 1;
elseif length(devices) - length(unique(devices)) ~= 0
    fprintf('\nError! You entered at least one device number more than once. Please try again.\n\n');
    error_flag = 1;
end

% If the error flag has been triggered at any point, reset the devices list
% back to zero so that the loop is run again
if error_flag == 1
    devices = 0;
end

end