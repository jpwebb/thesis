%% 1. Get images to process
id = 1;
S = dir(strcat('PointGrey_', num2str(id), filesep, '*.png'));
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
squareSize = 36;  % in units of 'millimeters'
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% [cx, cv, fx, fv] = initialGuess();
s = 0;
init_intrinsics = [];%[fx, 0, 0; s, fv, 0; cx, cv, 1];

%% 5. Calibrate the camera
[cameraParams, imagesUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
    'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
    'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', ...
    'InitialIntrinsicMatrix', init_intrinsics, 'InitialRadialDistortion', [], ...
    'ImageSize', [mrows, ncols]);

%% 6. View reprojection errors
h1=figure; showReprojectionErrors(cameraParams);
fprintf(['Mean Reprojection Error: ', ...
    num2str(cameraParams.MeanReprojectionError), ' pixels\n']);

%% 7. Visualize pattern locations
h2=figure; showExtrinsics(cameraParams, 'CameraCentric');

%% 8. Display parameter estimation errors
displayErrors(estimationErrors, cameraParams);

%% 9. For example, you can use the calibration data to remove effects of lens distortion.
[undistortedImage, newOrigin] = undistortImage(originalImage, cameraParams);

% See additional examples of how to use the calibration data.  At the prompt type:
% showdemo('MeasuringPlanarObjectsExample')
% showdemo('StructureFromMotionExample')

%% Display original and undistorted images

% Suppress warning message about display being too big
warning('off', 'Images:initSize:adjustingMag');

% Display the image pair
figure('Name', 'Original Image (left) and Undistorted Image (right)',...
    'NumberTitle', 'off');
imshowpair(originalImage, undistortedImage, 'montage');
