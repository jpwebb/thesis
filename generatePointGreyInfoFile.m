% This script sanity checks with an external csv file to define and store a
% struct with information related to the device IDs and serial numbers that
% have data associated with them.

% Load data from an externally maintained text file
fid = fopen('point_grey_device_info.txt');
if fid == -1       
    err_msg = sprintf(['\nFile not found!\n\nThe calibration tool ',...
        'depends on an external text file ',...
        'with device ID numbers (first column)\nand serial numbers ',...
        '(second column) called ''point_grey_device_info.txt''.\n\n',...
        'Generate this file and try again.\n']);
    my_error(err_msg);
    return;
end

h = waitbar(0, 'Please Wait...');

data = textscan(fid, '', 'delimiter', '\t', 'headerlines', 1);

% Strip the first column as IDs
ids = data{1};

% Strip the second column as Serial Numbers (left-padded with leading zeros
% such that all serial numbers are 12 digits)
serials = char(pad(string(data{2}), 12, 'left', '0'));

% Create an empty struct to be filled
PointGreyInfo = struct('ID', [], 'Serial', [], 'DataAvailable', false);

% Fill out the PointGreyInfo struct, where the available column is set to true
% or false based on whether the device has any images associated with it.
for i = 1:length(ids)
    waitbar(i/length(ids), h, sprintf(['Checking for images for device ID ', num2str(i)]));
    PointGreyInfo(i).ID = ids(i);
    PointGreyInfo(i).Serial = serials(i, :);
    PointGreyInfo(i).DataAvailable = false;
    contents = dir(['Point_Grey_', serials(i, :), filesep]);
    for j = find([contents.isdir] == 1)
        subfolder = contents(j).name;
        folder_to_check = strcat(['Point_Grey_', serials(i, :), filesep, subfolder, filesep]);
        images_found = checkForImages(folder_to_check);
        if images_found
            PointGreyInfo(i).DataAvailable = true;
            break;
        end
    end    
end

delete(h);

% Save the struct for use in the main program
save('Point_Grey_devices', 'PointGreyInfo');
