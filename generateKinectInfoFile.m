close all; clear; clc;

data = csvread('kinect_device_info.csv', 1);

ids = data(:,1);

serials = char(pad(string(data(:,2)), 12, 'left', '0'));

KinectInfo = struct('ID', [], 'Serial', []);

count = 0;

for i = 1:length(ids)
    if ~isempty(dir(['Kinect_', serials(i, :), filesep]))
        count = count + 1;
        KinectInfo(count).ID = ids(i);
        KinectInfo(count).Serial = serials(i, :);
    end
end

save('Kinect_devices', 'KinectInfo');
