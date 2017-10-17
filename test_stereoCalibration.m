close all; clear; clc;

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
squareSize = 90;  % in units of 'millimeters'
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
h2=figure; showExtrinsics(stereoParams, 'CameraCentric');

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
