function devices = getDevices(Kinect)

flag = 0;

min_device = min(cell2mat({Kinect.ID}'));
max_device = max(cell2mat({Kinect.ID}'));

device_list = cell2mat({Kinect.ID});
device_list = sort(device_list);
device_list = sprintf('%.0f, ' , device_list);
device_list = device_list(1:end-2);

fprintf(['The following device IDs are available for calibration: ', device_list, '.\n']);
devices = input('Enter the device IDs to calibrate: ', 's');
devices = str2num(devices);

if ~any(devices)
    disp('Uh oh, Invalid input. Please try again.');
    flag = 1;
elseif any(devices > max_device)
    disp('Uh oh, you entered a number that was too high. Please try again');
    flag = 1;
elseif any(devices < min_device)
    disp('Uh oh, you entered a number that was too low. Please try again');
    flag = 1;
elseif length(devices) > length(Kinect)
    disp('Uh oh, more devices chosen than data recorded. Please try again');
    flag = 1;
elseif length(devices) - length(unique(devices)) ~= 0
    disp('Uh oh, you entered at least one device number more than once. Please try again.');
    flag = 1;
end

if flag == 1
    devices = 0;
end

end