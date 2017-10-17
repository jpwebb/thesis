% This script generates a list of devices to calibrate via user-selected
% inputs. The user enters ID numbers in the form of a single number (e.g.
% "1" returns "[1]"), a list of specific numbers (e.g. "1, 3" returns "[1,
% 3]") or a list of continuous numbers (e.g. "1:3" returns "[1, 2, 3]").

function devices = getDevices(DeviceInfo)

% Initialise an error flag
error_flag = false;

% Generate a nice list of the device numbers (ordered and formatted)
device_list = strcat('ID_', char(string({DeviceInfo.ID})'), ',_Serial_', char({DeviceInfo.Serial}));
device_list = char(strrep(string(device_list), '_', ' '));

% Prompt the user for their input and convert the string into a number
fprintf('The following device IDs are available for calibration: \n\n');
disp(device_list);
devices = input('\nEnter the device ID(s) to calibrate: ', 's');
devices = str2num(devices);

if isempty(devices)
    clc;
    fprintf('Error, invalid input!\n\n');
    error_flag = true;
end

if ~error_flag
    first_time = true;
    for i = 1 : length(devices)
        if ~any(contains(string({DeviceInfo.ID}'), string(devices(i))))
            if first_time
                clc;
                first_time = false;
            end
            fprintf(['Error, device ID ', num2str(devices(i)), ' unavailable!\n']);
            error_flag = true;
        end
    end
    if error_flag
        fprintf('\n');
    end
end

if ~error_flag && (length(devices) - length(unique(devices)) ~= 0)
    clc;
    fprintf('Error, you entered at least one device ID more than once!\n\n');
    error_flag = true;
end

% If the error flag has been triggered at any point, reset the devices list
% back to zero so that the loop is run again
if error_flag
    devices = 0;
else
    fprintf('\n');
end

end