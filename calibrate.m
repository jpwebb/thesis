function cameraParams = calibrate(square_size, id, serial, im_folder)

%% 1. Get images to process
S = dir(strcat(im_folder, '*.png'));
c = struct2cell(S);
imageFileNames = strcat(c(2,:)', filesep, c(1,:)');

%% 2. Detect checkerboards in images & discard images with no target
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames, 'ShowProgressBar', 1);

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

if contains(im_folder, 'Kinect')
    [cx, cv, fx, fv] = initialGuess(im_folder);
    s = 0;
    init_intrinsics = [fx, 0, 0; s, fv, 0; cx, cv, 1];
elseif contains(im_folder, 'Point_Grey')
    init_intrinsics = [];
end
    

%% 5. Calibrate the camera
[cameraParams, ~, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
    'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
    'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', ...
    'InitialIntrinsicMatrix', init_intrinsics, 'InitialRadialDistortion', [], ...
    'ImageSize', [mrows, ncols]);

%% 6. View reprojection errors
h1=figure; showReprojectionErrors(cameraParams);
fprintf(['Mean Reprojection Error: ', ...
    num2str(cameraParams.MeanReprojectionError), ' pixels ', ...
    '(ID: ', num2str(id), ', Serial Number: ', serial, ')\n']);

%% 7. Visualize pattern locations
h2=figure; showExtrinsics(cameraParams, 'CameraCentric');

%% 8. Display parameter estimation errors
% displayErrors(estimationErrors, cameraParams);

%% 9. For example, you can use the calibration data to remove effects of lens distortion.
[undistortedImage, newOrigin] = undistortImage(originalImage, cameraParams);

% See additional examples of how to use the calibration data.  At the prompt type:
% showdemo('MeasuringPlanarObjectsExample')
% showdemo('StructureFromMotionExample')

end