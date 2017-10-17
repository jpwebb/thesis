% This script sanity checks with an external csv file to define and store a
% struct with information related to the device IDs and serial numbers that
% have data associated with them.

% Load data from an externally maintained text file
fid = fopen('kinect_device_info.txt');
if fid == -1
    fprintf('Error, file not found!\n\n');
    fprintf(['The calibration tool relies on an external text file ',...
        'with device ID numbers (first column)\nand serial numbers ',...
        '(second column) called ''kinect_device_info.txt''.\n\n',...
        'Generate this file and try again.\n']);
    return;
end
data = textscan(fid, '', 'delimiter', '\t', 'headerlines', 1);

% Strip the first column as IDs
ids = data{1};

% Strip the second column as Serial Numbers (left-padded with leading zeros
% such that all serial numbers are 12 digits)
serials = char(pad(string(data{2}), 12, 'left', '0'));

% Create an empty struct to be filled
KinectInfo = struct('ID', [], 'Serial', []);

% Initialise a count of devices that have been found to have data
count = 0;

% Add ID numbers and serial numbers to the struct, but only if the device
% seems to have some image data associated with it (in this instance, any
% directory that is not empty is kept)
for i = 1:length(ids)
    if ~isempty(dir(['Kinect_', serials(i, :), filesep]))
        count = count + 1;
        KinectInfo(count).ID = ids(i);
        KinectInfo(count).Serial = serials(i, :);
    end
end

% Save the struct for use in the main program
save('Kinect_devices', 'KinectInfo');
