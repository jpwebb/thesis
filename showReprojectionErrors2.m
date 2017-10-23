function ax = showReprojectionErrors2(cameraParams, id1, id2, varargin)
% showReprojectionErrors Visualize calibration errors.
%   showReprojectionErrors(cameraParams) displays a bar graph that
%   represents the calibration accuracy for a single camera or a stereo
%   pair. The bar graph displays the mean reprojection error per image.
%   cameraParams is either a cameraParameters object or a stereoParameters
%   object returned from the estimateCameraParameters function.
%
%   showReprojectionErrors(cameraParams, view) displays the
%   errors using the visualization style specified by the view
%   input.
%   Valid values of view:
%   'BarGraph':    Displays mean error per image as a bar graph.
%
%   'ScatterPlot': Displays the error for each point as a scatter plot.
%                  This option is available only for a single camera.
%
%                  Default: 'BarGraph'
%
%   ax = showReprojectionErrors(...) returns the plot's axes handle.
%
%   showReprojectionErrors(...,Name,Value) specifies additional
%   name-value pair arguments described below:
%
%   'HighlightIndex' Indices of selected images, specified as a
%   vector of integers. For the 'BarGraph' view, bars corresponding
%   to the selected images are highlighted. For 'ScatterPlot' view,
%   points corresponding to the selected images are displayed with
%   circle markers.
%
%   Default: []
%
%   'Parent'         Axes for displaying plot.
%
%   Class Support
%   -------------
%   cameraParameters must be a cameraParameters of a stereoParameters object.
%
%   Example 1 - Single camera
%   -------------------------
%   % Create a set of calibration images.
%   images = imageDatastore(fullfile(toolboxdir('vision'), 'visiondata', ...
%     'calibration', 'webcam'));
%   imageFileNames = images.Files(1:5);
%
%   % Detect calibration pattern.
%   [imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);
%
%   % Generate world coordinates of the corners of the squares.
%   squareSize = 25; % millimeters
%   worldPoints = generateCheckerboardPoints(boardSize, squareSize);
%
%   % Calibrate the camera.
%   I = readimage(images,1);
%   imageSize = [size(I, 1), size(I, 2)];
%   params = estimateCameraParameters(imagePoints, worldPoints, ...
%                                     'ImageSize', imageSize);
%
%   % Visualize the errors as a bar graph.
%   subplot(1, 2, 1);
%   showReprojectionErrors(params);
%
%   % Visualize the errors as a scatter plot.
%   subplot(1, 2, 2);
%   showReprojectionErrors(params, 'ScatterPlot');
%
%
%   Example 2 - Stereo camera
%   -------------------------
%   % Specify calibration images
%   imageDir = fullfile(toolboxdir('vision'), 'visiondata', ...
%       'calibration', 'stereo');
%   leftImages = imageDatastore(fullfile(imageDir, 'left'));
%   rightImages = imageDatastore(fullfile(imageDir, 'right'));
%
%   % Detect the checkerboards.
%   [imagePoints, boardSize] = detectCheckerboardPoints(...
%        leftImages.Files, rightImages.Files);
%
%   % Specify world coordinates of checkerboard keypoints.
%   squareSize = 108; % millimeters
%   worldPoints = generateCheckerboardPoints(boardSize, squareSize);
%
%   % Calibrate the stereo camera system. Here both cameras have the same
%   % resolution.
%   I = readimage(leftImages,1);
%   imageSize = [size(I, 1), size(I, 2)];
%   params = estimateCameraParameters(imagePoints, worldPoints, ...
%                                     'ImageSize', imageSize);
%
%   % Visualize calibration accuracy.
%   showReprojectionErrors(params);
%
%   See also showExtrinsics, estimateCameraParameters, cameraCalibrator,
%     stereoCameraCalibrator, cameraParameters, stereoParameters

%   Copyright 2014 The MathWorks, Inc.

[view, hAxes, highlightIndex] = parseInputs(cameraParams, varargin{:});


h = showReprojectionErrorsImpl2(cameraParams, id1, id2, view, hAxes, ...
    highlightIndex);

if nargout > 0
    ax = h;
end
end

%--------------------------------------------------------------------------
function [view, hAxes, highlightIndex] = ...
    parseInputs(cameraParams, varargin)

validateattributes(cameraParams, {'cameraParameters', ...
    'stereoParameters'}, {}, mfilename, 'cameraParams');

parser = inputParser;
parser.addOptional('View', 'BarGraph', @checkView);
parser.addParameter('HighlightIndex', [], @checkPatternIndex);
parser.addParameter('Parent', [], ...
    @vision.internal.inputValidation.validateAxesHandle);
parser.parse(varargin{:})

view = parser.Results.View;
hAxes = parser.Results.Parent;

% turn highlightIndex into a logical vector
highlightIndex = false(1,cameraParams.NumPatterns);
highlightIndex(unique(parser.Results.HighlightIndex)) = true;

%----------------------------------------------------------------------
    function tf = checkView(view)
        validatestring(view, {'barGraph', 'scatterPlot'}, ...
            'showReprojectionErrors', 'View');
        tf = true;
        if isa(cameraParams, 'stereoParameters') && ...
                strcmpi(view, 'scatterPlot')
            error(message('vision:calibrate:noStereoScatterPlot'));
        end
    end

%----------------------------------------------------------------------
% share this function between showReprojectionErrors and
% showExtrinsics
    function r = checkPatternIndex(in)
        r = true;
        if isempty(in) % empty is allowed
            return;
        end
        
        validateattributes(in, {'numeric'},...
            {'integer','vector', 'positive', '<=', cameraParams.NumPatterns}, ...
            'showReprojectionErrors', 'HighlightIndex');
    end
end

function hAxes = showReprojectionErrorsImpl2(this, id1, id2, ~, hAxes, highlightIndex)

hAxes = newplot(hAxes);

[meanError1, meanErrorsPerImage1] = ...
    computeMeanError(this.CameraParameters1);
[meanError2, meanErrorsPerImage2] = ...
    computeMeanError(this.CameraParameters2);
allErrors = [meanErrorsPerImage1, meanErrorsPerImage2];
meanError = mean([meanError1, meanError2]);

% Record the current 'hold' state so that we can restore it later
holdState = get(hAxes,'NextPlot');

% Plot the errors
hBar = bar(hAxes, allErrors);
set(hBar(1), 'FaceColor', [0, 0.7, 1]);
set(hBar(2), 'FaceColor', [242, 197, 148] / 255);
set(hBar, 'Tag', 'errorBars');

set(hAxes, 'NextPlot', 'add'); % hold on
hErrorLine = line(get(hAxes, 'XLim'), [meanError, meanError],...
    'LineStyle', '--', 'Parent', hAxes);

% Set AutoUpdate to off to prevent other items from appearing
% automatically in the legend.
legend([hBar, hErrorLine], strrep(strcat('Camera_', num2str(id2)), '_', ' '),...
    strrep(strcat('Camera_', num2str(id1)), '_', ' '), ...
    getString(message(...
    'vision:calibrate:overallMeanError', ...
    sprintf('%.2f', meanError))), ...
    'Location', 'SouthEast', ...
    'AutoUpdate', 'off');

% Plot highlighted errors
highlightedErrors = allErrors;
highlightedErrors(~highlightIndex, :) = 0;
hHighlightedBar = bar(hAxes, highlightedErrors);
set(hHighlightedBar(1), 'FaceColor', [0 0 1]);
set(hHighlightedBar(2), 'FaceColor', [190, 101, 1] ./ 255);
set(hHighlightedBar, 'Tag', 'highlightedBars');

set(hAxes, 'NextPlot', holdState); % restore the hold state

title(hAxes, getString(message('vision:calibrate:barGraphTitle')));
xlabel(hAxes, getString(message('vision:calibrate:barGraphXLabelStereo')));
ylabel(hAxes, getString(message('vision:calibrate:barGraphYLabel')));
end