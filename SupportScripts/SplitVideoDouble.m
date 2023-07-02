function [videoB, videoV, Bfi, Vfi] = SplitVideoDouble(vfile_1, vfile_2, cpos)
%% Created by Hemanth Mohan, modified by Hermione Xu.
%%
tiff_info_1 = imfinfo(vfile_1);
tiff_info_2 = imfinfo(vfile_2);

videoB_1 = [];
videoV_1 = [];
Vfi_1 = [];
Bfi_1 = [];

videoB_2 = [];
videoV_2 = [];
Vfi_2 = [];
Bfi_2 = [];

% load and split video 1
parfor fi = 1:size(tiff_info_1,1) % fi is the file index
    if rem(fi,2) == 1
        videoB_temp = imcrop(imread(vfile_1,fi),cpos);
        videoB_1 = [videoB_1 videoB_temp];
        Bfi_1 = [Bfi_1; fi]; % Frame numbers of blue frames
    else
        videoV_temp= imcrop(imread(vfile_1,fi),cpos);
        videoV_1 = [videoV_1 videoV_temp];
        Vfi_1 = [Vfi_1;fi]; % Frame numbers of violet frames
    end
end
% load and split video 2
parfor fi = 1:size(tiff_info_2,1)
    if rem(fi,2) == 1
        videoV_temp= imcrop(imread(vfile_2,fi),cpos);
        videoV_2 = [videoV_2 videoV_temp];
        Vfi_2 = [Vfi_2;fi]; % Frame numbers of violet frames
    else
        videoB_temp = imcrop(imread(vfile_2,fi),cpos);
        videoB_2 = [videoB_2 videoB_temp];
        Bfi_2 = [Bfi_2;fi]; % Frame numbers of blue frames
    end
end
% Combine blue together and violet together
Imsize = size(imcrop(imread(vfile_1,1),cpos));

videoB_1 = reshape(videoB_1,Imsize(1),Imsize(2),[]);
videoV_1 = reshape(videoV_1,Imsize(1),Imsize(2),[]);

videoB_2 = reshape(videoB_2,Imsize(1),Imsize(2),[]);
videoV_2 = reshape(videoV_2,Imsize(1),Imsize(2),[]);

videoB = cat(3,videoB_1,videoB_2);
videoV = cat(3,videoV_1,videoV_2);
Bfi = [Bfi_1;Bfi_2];
Vfi = [Vfi_1;Vfi_2];
end