close all; clc;

%% 1. Get images to process
S = dir(strcat('/Users/jasonwebb/Documents/GitHub/thesis/Kinect_005224162247/Overlap', filesep, '*.png'));
c = struct2cell(S);
imageFileNames1 = strcat(c(2,:)', filesep, c(1,:)');

S = dir(strcat('/Users/jasonwebb/Documents/GitHub/thesis/Kinect_080723134947/Overlap', filesep, '*.png'));
c = struct2cell(S);
imageFileNames2 = strcat(c(2,:)', filesep, c(1,:)');

%% 2. Detect checkerboards in images & discard images with no target
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames1, imageFileNames2, 'ShowProgressBar', 1);

% imageFileNamesNoBoard = imageFileNames(imcomplement(imagesUsed));
% if ~isempty(imageFileNamesNoBoard)
%     
%     delete(imageFileNamesNoBoard{:});
% end

imageFileNames1 = imageFileNames1(imagesUsed);
imageFileNames2 = imageFileNames2(imagesUsed);

%% 3. Read the first image to obtain image size
I1 = imread(imageFileNames1{1});
[mrows, ncols, ~] = size(I1);

%% 4. Generate world coordinates of the corners of the squares
squareSize = 36;  % in units of 'millimeters'
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% [cx, cv, fx, fv] = initialGuess();
s = 0;
init_intrinsics = [];%[fx, 0, 0; s, fv, 0; cx, cv, 1];

%% 5. Calibrate the camera
[stereoParams, pairsUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
    'EstimateSkew', false, 'EstimateTangentialDistortion', true, ...
    'NumRadialDistortionCoefficients', 3, 'WorldUnits', 'millimeters', ...
    'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
    'ImageSize', [mrows, ncols]);

%% 6. View reprojection errors
h1=figure; showReprojectionErrors(stereoParams);
fprintf(['Mean Reprojection Error: ', ...
    num2str(stereoParams.MeanReprojectionError), ' pixels\n']);

%% 7. Visualize pattern locations
h2=figure; showExtrinsics2(stereoParams, 'CameraCentric');

fprintf(['\nComputed Translation, ', ...
    'x: ', num2str(stereoParams.TranslationOfCamera2(1), 4), ' mm, ', ...
    'y: ', num2str(stereoParams.TranslationOfCamera2(2), 4), ' mm, ', ...
    'z: ', num2str(stereoParams.TranslationOfCamera2(3), 4), ' mm.\n']);

%% 8. Display parameter estimation errors
% displayErrors(estimationErrors, stereoParams);

%% 9. You can use the calibration data to rectify stereo images.
% I2 = imread(imageFileNames2{1});
% [J1, J2] = rectifyStereoImages(I1, I2, stereoParams);

% See additional examples of how to use the calibration data.  At the prompt type:
% showdemo('MeasuringPlanarObjectsExample')
% showdemo('StructureFromMotionExample')

%% Display original and undistorted images

% % Suppress warning message about display being too big
% warning('off', 'Images:initSize:adjustingMag');
% 
% % Display the image pair
% figure('Name', 'Original Image (left) and Undistorted Image (right)',...
%     'NumberTitle', 'off');
% imshowpair(I1, undistortedImage, 'montage');
