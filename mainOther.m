function mainOther()

default_square_size = 90;

im_folder = uigetdir('', 'Select a folder with images for calibration');

im_list = getImageList(im_folder);

if isempty(im_list)
    warning_msg = 'No images found in selected folder!\n';
    my_warning(warning_msg);
    return;
end

square_size = getSquareSize(default_square_size);

cameraParams = calibrate(square_size, 'N/A', 'Unknown', im_folder);

if ~isempty(cameraParams)
    fprintf('Calibration complete!\n');
    fprintf(['\nNumber of images with a valid calibration target: ', num2str(cameraParams.NumPatterns), ' (out of ', num2str(length(im_list)), ' images)\n']);
    fprintf(['\nMean reprojection error: ', num2str(cameraParams.MeanReprojectionError), '\n']);
    fprintf(['\nImage size: ', num2str(cameraParams.ImageSize(2)), ' x ', num2str(cameraParams.ImageSize(1)), ' pixels\n']);
    fprintf(['\nFocal length:\n  fx: ', num2str(cameraParams.FocalLength(1)), '\n  fy: ', num2str(cameraParams.FocalLength(2)), '\n']);
    fprintf(['\nPrincipal point:\n  cx: ', num2str(cameraParams.PrincipalPoint(1)), '\n  cy: ', num2str(cameraParams.PrincipalPoint(2)), '\n']);
    fprintf('\n');
end

end