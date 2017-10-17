function cameraParams = calibrate(square_size, id, serial, im_folder)

%% 1. Get images to process
imageFileNames = getImageList(im_folder);

%% 2. Detect checkerboards in images & discard images with no target
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints2(imageFileNames, 'ShowProgressBar', 1);

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

fprintf(['Mean Reprojection Error: ', ...
    num2str(cameraParams.MeanReprojectionError), ' pixels ', ...
    '(ID: ', num2str(id), ', Serial Number: ', serial, ')\n']);

%% 8. Visualize pattern locations
h2 = figure; showExtrinsics(cameraParams, 'CameraCentric');

%% 9. Display parameter estimation errors
displayErrors(estimationErrors, cameraParams);

%% 10. For example, you can use the calibration data to remove effects of lens distortion.
[undistortedImage, newOrigin] = undistortImage(originalImage, cameraParams);

%% 11. View projected points
imOrig = imread(imageFileNames{4});
figure, imshow(imOrig, 'InitialMagnification', 100);
imUndistorted = undistortImage(imOrig,cameraParams);
[imagePoints, boardSize] = detectCheckerboardPoints2(imUndistorted);
worldPoints = generateCheckerboardPoints(boardSize, square_size);
[R,t] = extrinsics(imagePoints,worldPoints,cameraParams);
zCoord = zeros(size(worldPoints,1),1);
worldPoints = [worldPoints zCoord];
projectedPoints = worldToImage(cameraParams, R, t, worldPoints);
hold on
% plot(imagePoints(:, 1), imagePoints(:, 2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
plot(projectedPoints(:, 1), projectedPoints(:, 2), 'b+', 'MarkerSize', 20, 'LineWidth', 2);
legend('Projected points');
hold off


%%

% See additional examples of how to use the calibration data.  At the prompt type:
% showdemo('MeasuringPlanarObjectsExample')
% showdemo('StructureFromMotionExample')

end