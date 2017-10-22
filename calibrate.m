function cameraParams = calibrate(square_size, id, serial, im_folder)

% Extract the device type from the image folder name
device_type = regexprep(im_folder, '\d[0-9_]+\d', '*');
temp_idx = find(device_type ==  '*', 1);
device_type = strrep(device_type(1:temp_idx-2), '_', ' ');

if ~(strcmpi(device_type, 'Point Grey') || strcmpi(device_type, 'Kinect'))
    device_type = 'Unknown';
end

%% 1. Get images to process
imageFileNames = getImageList(im_folder);

min_images = 3;

if length(imageFileNames) < min_images
    warning_msg = ['Only ', num2str(length(imageFileNames)), ' image(s) found!',...
        ' The minimum required number of images for calibration is ', num2str(min_images),...
        ' (', device_type, ' device: ID ', num2str(id), ', Serial Number ', serial, ').\n\n'];
    my_warning(warning_msg);
    cameraParams = [];
    return;
end

%% 2. Detect checkerboards in images & discard images with no target
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints2(imageFileNames, 'ShowProgressBar', 1);

if sum(imagesUsed) < min_images
    warning_msg = ['Calibration target only detected in ', num2str(sum(imagesUsed)), ' image(s)!',...
        ' The minimum required number of images for calibration is ', num2str(min_images),...
        ' (', device_type, ' device ID ', num2str(id), ', Serial Number ', serial, ').\n\n'];
    my_warning(warning_msg);
    cameraParams = [];
    return;
end

imageFileNamesNoBoard = imageFileNames(imcomplement(imagesUsed));
if ~isempty(imageFileNamesNoBoard)
    
    delete(imageFileNamesNoBoard{:});
end
imageFileNames = imageFileNames(imagesUsed);

%% 3. Read the first image to obtain image size
originalImage = imread(imageFileNames{1});
[mrows, ncols, ~] = size(originalImage);

%% 4. Generate world coordinates of the corners of the squares
worldPoints = generateCheckerboardPoints(boardSize, square_size);

%% 5. Get initial intrinsic parameters
init_intrinsics = getInitIntrinsics(im_folder);

%% 6. Calibrate the camera
[cameraParams, ~, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
    'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
    'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', ...
    'InitialIntrinsicMatrix', init_intrinsics, 'InitialRadialDistortion', [], ...
    'ImageSize', [mrows, ncols]);

%% 7. View reprojection errors
h1 = figure; showReprojectionErrors(cameraParams);

% fprintf(['Mean Reprojection Error: ', ...
%     num2str(cameraParams.MeanReprojectionError), ' pixels ', ...
%     '(ID: ', num2str(id), ', Serial Number: ', serial, ')\n']);

%% 8. Visualize pattern locations
h2 = figure; showExtrinsics(cameraParams, 'CameraCentric');

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