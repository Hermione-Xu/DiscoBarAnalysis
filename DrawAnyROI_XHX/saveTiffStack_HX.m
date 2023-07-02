function [] = saveTiffStack_HX(im_stack, im_filename)
% Prompt for directory to save the file
folder_path = uigetdir;
parsed = split(im_filename,["\","."]);
file_path = join([folder_path, join([parsed(4), parsed(6),'mc.tif'],'_')],'\');
for ind=1:size(im_stack,3)
    if ~exist(string(file_path),'file')
        imwrite(uint16(im_stack(:,:,ind)),char(file_path));
    else
        imwrite(uint16(im_stack(:,:,ind)), char(file_path), 'writemode', 'append');
    end
end
return