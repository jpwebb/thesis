close all; clear; clc;

data = csvread('kinect_device_info.csv', 1);

ids = data(:,1);

serials = char(pad(string(data(:,2)), 12, 'left', '0'));

KinectInfo = struct('ID', [], 'Serial', []);

for i = 1:length(ids)
    KinectInfo(i).ID = ids(i);
    KinectInfo(i).Serial = serials(i, :);
end

save('Kinect_devices', 'KinectInfo');
