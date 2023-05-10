%% File created on Apr. 18, 2023 by Hermione Xu
%  Code from MATLAB: https://www.mathworks.com/help/images/use-wait-function-after-drawing-roi-example.html
function clickCallback(~,evt)

if strcmp(evt.SelectionType,'double')
    uiresume;
end

end