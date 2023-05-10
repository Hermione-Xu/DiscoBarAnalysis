function [videoB videoV Bfi Vfi] = SplitVideo_XHX(vfile,cpos)
tiff_info = imfinfo(vfile);
videoB=[];
videoV=[];
Vfi = [];
Bfi = [];

parfor fi = 1:size(tiff_info,1)
    if rem(fi,2) == 1
        videoB_temp = imcrop(imread(vfile,fi),cpos);
        videoB = [videoB videoB_temp];
        Bfi = [Bfi;fi]; % Frame numbers of blue frames
    else
        videoV_temp= imcrop(imread(vfile,fi),cpos);
        videoV = [videoV videoV_temp];
        Vfi = [Vfi;fi]; % Frame numbers of violet frames
    end
end

Imsize = size(imcrop(imread(vfile,1),cpos));
 
videoB = reshape(videoB,Imsize(1),Imsize(2),[]);
videoV = reshape(videoV,Imsize(1),Imsize(2),[]);
end

