function removeFigBorder()
% Sourced from:
% https://au.mathworks.com/matlabcentral/answers/100366-how-can-i-remove
% -the-grey-borders-from-the-imshow-plot-in-matlab-7-4-r2007a

% set the axes units to pixels
set(gca,'units','pixels');
% get the position of the axes
x = get(gca,'position');
% set the figure units to pixels
set(gcf,'units','pixels');
% get the figure position
y = get(gcf,'position');
% set the position of the figure to the length and width of the axes
set(gcf,'position',[y(1) y(2) x(3) x(4)]);
% set the axes units to pixels
set(gca,'units','normalized','position',[0 0 1 1]);
end