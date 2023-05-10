%% File created on Apr. 18, 2023 by Hermione Xu
%  Code from MATLAB: https://www.mathworks.com/help/images/use-wait-function-after-drawing-roi-example.html
function pos = customWait(hROI)

% Listen for mouse clicks on the ROI
l = addlistener(hROI,'ROIClicked',@clickCallback);

% Block program execution
uiwait;

% Remove listener
delete(l);

% Return the current position
pos = hROI.Position;

end