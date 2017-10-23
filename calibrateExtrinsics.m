function stereoParams = calibrateExtrinsics(square_size, id1, serial1, im_folder1, id2, serial2, im_folder2)

% Extract the device type from the image folder name
device_type1 = regexprep(im_folder1, '\d[0-9_]+\d', '*');
temp_idx1 = find(device_type1 ==  '*', 1);
device_type1 = strrep(device_type1(1:temp_idx1-2), '_', ' ');

if ~(strcmpi(device_type1, 'Point Grey') || strcmpi(device_type1, 'Kinect'))
    device_type1 = 'Unknown';
end

device_type2 = regexprep(im_folder2, '\d[0-9_]+\d', '*');
temp_idx2 = find(device_type2 ==  '*', 1);
device_type2 = strrep(device_type2(1:temp_idx2-2), '_', ' ');

if ~(strcmpi(device_type2, 'Point Grey') || strcmpi(device_type2, 'Kinect'))
    device_type2 = 'Unknown';
end

%% 1. Get images to process
imageFileNames1 = getImageList(im_folder1);

min_images = 3;

if length(imageFileNames1) < min_images
    warning_msg = ['Only ', num2str(length(imageFileNames1)), ' image(s) found!',...
        ' The minimum required number of images for calibration is ', num2str(min_images),...
        ' (', device_type1, ' device: ID ', num2str(id1), ', Serial Number ', serial1, ').\n\n'];
    my_warning(warning_msg);
    stereoParams = [];
    return;
end

imageFileNames2 = getImageList(im_folder2);

if length(imageFileNames2) < min_images
    warning_msg = ['Only ', num2str(length(imageFileNames2)), ' image(s) found!',...
        ' The minimum required number of images for calibration is ', num2str(min_images),...
        ' (', device_type2, ' device: ID ', num2str(id2), ', Serial Number ', serial2, ').\n\n'];
    my_warning(warning_msg);
    stereoParams = [];
    return;
end

%% 2. Detect checkerboards in images & discard images with no target
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints2(imageFileNames2, imageFileNames1, 'ShowProgressBar', 1);

if sum(imagesUsed) < min_images
    warning_msg = ['Calibration target only detected in ', num2str(sum(imagesUsed)), ' image(s)!',...
        ' The minimum required number of images for calibration is ', num2str(min_images), '.\n\n'];
    my_warning(warning_msg);
    stereoParams = [];
    return;
end

imageFileNames1 = imageFileNames1(imagesUsed);
imageFileNames2 = imageFileNames2(imagesUsed);

%% 3. Read the first image to obtain image size
originalImage = imread(imageFileNames1{1});
[mrows, ncols, ~] = size(originalImage);

%% 4. Generate world coordinates of the corners of the squares
worldPoints = generateCheckerboardPoints(boardSize, square_size);

%% 6. Calibrate the camera
[stereoParams, pairsUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
    'EstimateSkew', false, 'EstimateTangentialDistortion', true, ...
    'NumRadialDistortionCoefficients', 3, 'WorldUnits', 'millimeters', ...
    'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
    'ImageSize', [mrows, ncols]);

%% 7. View reprojection errors
h1 = figure; showReprojectionErrors(stereoParams);
fprintf(['Mean Reprojection Error: ', ...
    num2str(stereoParams.MeanReprojectionError), ' pixels\n']);

% fprintf(['Mean Reprojection Error: ', ...
%     num2str(cameraParams.MeanReprojectionError), ' pixels ', ...
%     '(ID: ', num2str(id), ', Serial Number: ', serial, ')\n']);

%% 8. Visualize pattern locations
h2 = figure;
showExtrinsics2(stereoParams, id1, id2, 'CameraCentric');
set(gca, 'FontSize', 14);

%% 9. Display parameter estimation errors
% displayErrors(estimationErrors, cameraParams);

%% 10. For example, you can use the calibration data to remove effects of lens distortion.
% [undistortedImage, newOrigin] = undistortImage(originalImage, cameraParams);

%% 11. View image/projected points

% imOrig = imread(imageFileNames{4});
% % imOrig = I2;
% my_fig = figure;
% imshow(imOrig, 'InitialMagnification', 100);
% imUndistorted = undistortImage(imOrig,cameraParams);
% [imagePoints, boardSize] = detectCheckerboardPoints2(imUndistorted);
% worldPoints = generateCheckerboardPoints(boardSize, square_size);
% [R,t] = extrinsics(imagePoints,worldPoints,cameraParams);
% zCoord = zeros(size(worldPoints,1),1);
% worldPoints = [worldPoints zCoord];
% projectedPoints = worldToImage(cameraParams, R, t, worldPoints);
% hold on
% % plot(imagePoints(:, 1), imagePoints(:, 2), 'r.', 'MarkerSize', 20, 'LineWidth', 2);
% % plot(projectedPoints(:, 1), projectedPoints(:, 2), 'b.', 'MarkerSize', 20, 'LineWidth', 2);
% % lgd = legend('Projected points', 'Location', 'none');
% % lgd_rect = [0.48, 0.7, 0, 0];
% % set(lgd, 'Position', lgd_rect)
% hold off;
% my_frame = getframe(my_fig);
% im2 = my_frame.cdata;
% % [~, rect] = imcrop(im2);
% 
% im_cropped = imcrop(im2, rect);
% figure, imshow(im_cropped);
%%

% See additional examples of how to use the calibration data.  At the prompt type:
% showdemo('MeasuringPlanarObjectsExample')
% showdemo('StructureFromMotionExample')

end