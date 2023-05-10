%%
% Built: 2018
% Creator: Hemanth Mohan, Cold Spring Harbor Laboratory
% Contact: mohan@cshl.edu
%%

function [cpos, refimg] = MakeCoorFile(fpath,vfile,coorfile)
    v1 = imread(vfile,1);
    figure
    [refimg,cpos] = imcrop(imadjust(v1,[0 0.3]));
    close(gcf)
    coorsave = input('Do you want to save the coordinate position (Yes = 1, No = 0): ');
    if coorsave == 1
        save(fullfile(fpath,coorfile), 'cpos');
        save(fullfile(fpath,[coorfile(1:end-8) 'refimg']),'refimg');
    end
end

