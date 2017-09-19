clc;

n = 5;

im1 = imread('Kinect_080723134947/Overlap/19092017_003.png');

im2 = imread('Kinect_005224162247/Overlap/19092017_003.png');

cameraParams1 = KinectParams(1).deviceParams;

cameraParams2 = KinectParams(2).deviceParams;

im1u = undistortImage(im1, cameraParams1);

im2u = undistortImage(im2, cameraParams2);

points1 = detectCheckerboardPoints(im1u);

points2 = detectCheckerboardPoints(im2u);

% figure, imshow(im1u), hold on, scatter(points1(:,1), points1(:,2), 'g'), hold off;

% figure, imshow(im2u), hold on, scatter(points2(:,1), points2(:,2), 'g'), hold off;

sum = zeros(1, 3);

for i = 1:n
    
    [M, inliersIndex] = estimateFundamentalMatrix(points1, points2);
    
    inlierPoints1 = points1(inliersIndex, :);
    
    inlierPoints2 = points2(inliersIndex, :);
    
    [relativeOrientation, relativeLocation] = relativeCameraPose(M, cameraParams1, cameraParams2, inlierPoints1, inlierPoints2);
    
    [rotationMatrix, translationVector] = cameraPoseToExtrinsics(relativeOrientation, relativeLocation);
    
    % stereoParams2 = stereoParameters(cameraParams1, cameraParams2, rotationMatrix, translationVector);
    %
    % h2=figure; showExtrinsics(stereoParams2, 'CameraCentric');
    
    fprintf(['Estimated Translation (', num2str(i), '), ', ...
        'x: ', num2str(translationVector(1), '%.3f'), ' m, ', ...
        'y: ', num2str(translationVector(2), '%.3f'), ' m, ', ...
        'z: ', num2str(translationVector(3), '%.3f'), ' m.\n']);
    
    sum = sum + translationVector;
    
end

avg_translation = sum ./ n;

fprintf(['\nAverage Translation, over ', num2str(n), ' runs, ', ...
    'x: ', num2str(avg_translation(1), '%.3f'), ' m, ', ...
    'y: ', num2str(avg_translation(2), '%.3f'), ' m, ', ...
    'z: ', num2str(avg_translation(3), '%.3f'), ' m.\n']);