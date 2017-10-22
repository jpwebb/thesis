close all; clear; clc;

squareSize = 90;  % in units of 'millimeters'

%% 1. Get images to process

directory1 = '/Users/jasonwebb/Documents/GitHub/thesis/temp/cam1';
imageFileNames1 = getImageList(directory1);
clear directory1

%%

directory2 = '/Users/jasonwebb/Documents/GitHub/thesis/temp/cam2';
imageFileNames2 = getImageList(directory2);
clear directory2

%%
% for i = 1 : length(imageFileNames1)
%     figure, imshowpair(imread(char(imageFileNames1(i))), imread(char(imageFileNames2(i))), 'montage');
%     pause();
%     close all;
% end

%% Single One

imageFileNames = imageFileNames1;
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints2(imageFileNames, 'ShowProgressBar', 1);
imageFileNames = imageFileNames(imagesUsed);
originalImage = imread(imageFileNames{1});
[mrows, ncols, ~] = size(originalImage);
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
[cameraParams, ~, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
    'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
    'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', ...
    'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
    'ImageSize', [mrows, ncols]);
h1 = figure; showReprojectionErrors(cameraParams);
set(gca, 'FontSize', 14);
h2 = figure; showExtrinsics(cameraParams, 'CameraCentric');
set(gca, 'FontSize', 14);

%% Single Two

imageFileNames = imageFileNames2;
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints2(imageFileNames, 'ShowProgressBar', 1);
imageFileNames = imageFileNames(imagesUsed);
originalImage = imread(imageFileNames{1});
[mrows, ncols, ~] = size(originalImage);
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
[cameraParams, ~, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
    'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
    'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', ...
    'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
    'ImageSize', [mrows, ncols]);
h1 = figure; showReprojectionErrors(cameraParams);
set(gca, 'FontSize', 14);
h2 = figure; showExtrinsics(cameraParams, 'CameraCentric');
set(gca, 'FontSize', 14);

%% Stereo

%% 2. Detect checkerboards in images & discard images with no target
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints2(imageFileNames1, imageFileNames2, 'ShowProgressBar', 1);

% imageFileNamesNoBoard = imageFileNames(imcomplement(imagesUsed));
% if ~isempty(imageFileNamesNoBoard)
%     
%     delete(imageFileNamesNoBoard{:});
% end

if sum(imagesUsed) <= 2
    fprintf('Error, not enough checkerboard patterns detected.\n');
    fprintf('Must be greater than 2.\n');
    return;
end

imageFileNames1 = imageFileNames1(imagesUsed);
imageFileNames2 = imageFileNames2(imagesUsed);

%% 3. Read the first image to obtain image size
I1 = imread(imageFileNames1{1});
[mrows, ncols, ~] = size(I1);

%% 4. Generate world coordinates of the corners of the squares

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
set(gca, 'FontSize', 14);
%% 
h2=figure;
showExtrinsics(stereoParams, 'CameraCentric');
set(gca, 'FontSize', 14);

%% 7. Visualize pattern locations
h3=figure;
showExtrinsics3(stereoParams, 'CameraCentric');
set(gca, 'FontSize', 14);
hold on;

for i = 1:3
    
stereoParams2 = toStruct(stereoParams);
% t2 = (stereoParams2.RotationOfCamera2 * stereoParams2.TranslationOfCamera2' + stereoParams.TranslationOfCamera2')';
% stereoParams2.TranslationOfCamera2 = t2;
% stereoParams2.RotationOfCamera2 = eye(3);
stereoParams2 = stereoParameters(stereoParams2);
showExtrinsics2(stereoParams2, 1, 2, 'CameraCentric');

stereoParams3 = toStruct(stereoParams);
t3 = (stereoParams3.RotationOfCamera2 * stereoParams3.TranslationOfCamera2' + stereoParams.TranslationOfCamera2')';
stereoParams3.TranslationOfCamera2 = t3;
stereoParams3.RotationOfCamera2 = eye(3);
stereoParams3 = stereoParameters(stereoParams3);
showExtrinsics2(stereoParams3, 1, 3, 'CameraCentric');

stereoParams4 = toStruct(stereoParams);
t4 = (stereoParams4.RotationOfCamera2 * stereoParams4.TranslationOfCamera2' + stereoParams.TranslationOfCamera2')';
stereoParams4.TranslationOfCamera2 = 1.5 * t4;
stereoParams4.RotationOfCamera2 = eye(3);
stereoParams4 = stereoParameters(stereoParams4);
showExtrinsics2(stereoParams4, 1, 4, 'CameraCentric');

stereoParams5 = toStruct(stereoParams);
t5 = (stereoParams5.RotationOfCamera2 * stereoParams5.TranslationOfCamera2' + stereoParams5.TranslationOfCamera2')';
stereoParams5.TranslationOfCamera2 = 2 * t5;
stereoParams5.RotationOfCamera2 = eye(3);
stereoParams5 = stereoParameters(stereoParams5);
showExtrinsics2(stereoParams5, 1, 5, 'CameraCentric');

stereoParams6 = toStruct(stereoParams);
t6 = (stereoParams6.RotationOfCamera2 * stereoParams6.TranslationOfCamera2' + stereoParams6.TranslationOfCamera2')';
stereoParams6.TranslationOfCamera2 = 2.5 * t6;
stereoParams6.RotationOfCamera2 = eye(3);
% stereoParams6.CameraParameters1.WorldPoints(:, 1) = stereoParams6.CameraParameters1.WorldPoints(:, 1) + 2000;
% stereoParams6.CameraParameters2.WorldPoints(:, 1) = stereoParams6.CameraParameters2.WorldPoints(:, 1) + 2000;
stereoParams6 = stereoParameters(stereoParams6);
showExtrinsics2(stereoParams6, 1, 6, 'CameraCentric');

fprintf(['\nComputed Translation, ', ...
    'x: ', num2str(stereoParams.TranslationOfCamera2(1), 4), ' mm, ', ...
    'y: ', num2str(stereoParams.TranslationOfCamera2(2), 4), ' mm, ', ...
    'z: ', num2str(stereoParams.TranslationOfCamera2(3), 4), ' mm.\n']);
end


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


%% Testing area

extrinsic_params = struct('R', [], 't', []);

extrinsic_params(1).R = eye(3);
% extrinsic_params;

