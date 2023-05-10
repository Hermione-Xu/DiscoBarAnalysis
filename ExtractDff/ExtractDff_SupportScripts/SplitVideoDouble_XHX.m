function [videoB, videoV, Bfi, Vfi] = SplitVideoDouble_XHX(ops)
%% Created by Hemanth Mohan, modified by Hermione Xu.
%%
vfile_1 = ops.vfile_1;
vfile_2 = ops.vfile_2;
pos = ops.pos;
refimg = ops.refimg;
tiff_info_1 = imfinfo(vfile_1);
tiff_info_2 = imfinfo(vfile_2);

totalframes = size(tiff_info_1,1) + size(tiff_info_2,1);
videoB=zeros(size(refimg,1),size(refimg,2),ceil(totalframes/2));
videoV=zeros(size(refimg,1),size(refimg,2),floor(totalframes/2));
Bfi = zeros(1,ceil(totalframes/2));
Vfi = zeros(1,floor(totalframes/2));

% videoB_2=zeros(size(refimg,1),size(refimg,2),ceil(size(tiff_info_2,1)/2));
% videoV_2=zeros(size(refimg,1),size(refimg,2),floor(size(tiff_info_2,1)/2));
% Bfi_2 = zeros(1,ceil(size(tiff_info_2,1)/2));
% Vfi_2 = zeros(1,floor(size(tiff_info_2,1)/2));

tic
%% First video 1 (didn't do parfor because couldn't find a good solution to
% the "slicing" indexing issue.
for fi = 1:size(tiff_info_1,1) % fi is the frame index
    if rem(fi,2) == 1
        % videoB_temp = imcrop(imread(vfile_1,fi),pos);
        % videoB_temp(~refimg)=0;
        % videoB(:,:,(fi+1)/2) = videoB_temp; % Faster than array concatenation
        videoB(:,:,(fi+1)/2)=imread(vfile_1,fi);
        Bfi(1,(fi+1)/2) = fi; % Frame numbers of blue frames
    else
        % videoV_temp= imcrop(imread(vfile_1,fi),pos);
        % videoV_temp(~refimg)=0;
        % videoV(:,:,fi/2) = videoV_temp; % Faster than array concatenation
        videoV(:,:,fi/2) = imread(vfile_1,fi);
        Vfi(1,fi/2) = fi; % Frame numbers of blue frames
    end
end

%% Then the second video
for fi = 1+size(tiff_info_1,1):size(tiff_info_1,1)+size(tiff_info_2,1)
    % v2_ind = fi - size(tiff_info_1,1);
    if rem(fi,2) == 1
        % videoB_temp = imcrop(imread(vfile_2,v2_ind),pos);
        % videoB_temp(~refimg)=0;
        % videoB(:,:,(fi+1)/2) = videoB_temp; 
        videoB(:,:,(fi+1)/2)=imread(vfile_2,fi);
        Bfi(1,(fi+1)/2) = fi; % Frame numbers of blue frames
    else
        % videoV_temp= imcrop(imread(vfile_1,v2_ind),pos);
        % videoV_temp(~refimg)=0;
        % videoV(:,:,fi/2) = videoV_temp; 
        videoV(:,:,fi/2) = imread(vfile_2,fi);
        Vfi(1,fi/2) = fi; % Frame numbers of blue frames
    end
end
toc

%% load and split video 1
% parfor fi = 1:size(tiff_info_1,1) % fi is the file index
%     if rem(fi,2) == 1
%         videoB_temp = imcrop(imread(vfile_1,fi),pos);
%         videoB_temp(~refim)=0;
%         videoB_1(:,:,(fi+1)/2) = videoB_temp; % Faster than array concatenation
%         %Bfi_1(1,(fi+1)/2) = fi; % Frame numbers of blue frames
%     else
%         videoV_temp= imcrop(imread(vfile_1,fi),pos);
%         videoV_temp(~refim)=0;
%         videoV_1(:,:,(fi+1)/2) = videoV_temp; % Faster than array concatenation
%         Vfi_1(1,(fi+1)/2) = fi; % Frame numbers of blue frames
%     end
% end
%% load and split video 2
% parfor fi = 1:size(tiff_info_2,1)
%     if rem(fi,2) == 1
%         videoV_temp= imcrop(imread(vfile_2,fi),pos);
%         videoV_2 = [videoV_2 videoV_temp];
%         Vfi_2 = [Vfi_2;fi]; % Frame numbers of violet frames
%     else
%         videoB_temp = imcrop(imread(vfile_2,fi),pos);
%         videoB_2 = [videoB_2 videoB_temp];
%         Bfi_2 = [Bfi_2;fi]; % Frame numbers of blue frames
%     end
% end
%% Combine blue together and violet together
% Imsize = size(imcrop(imread(vfile_1,1),pos));
% 
% videoB_1 = reshape(videoB_1,Imsize(1),Imsize(2),[]);
% videoV_1 = reshape(videoV_1,Imsize(1),Imsize(2),[]);
% 
% videoB_2 = reshape(videoB_2,Imsize(1),Imsize(2),[]);
% videoV_2 = reshape(videoV_2,Imsize(1),Imsize(2),[]);
% 
% videoB = cat(3,videoB_1,videoB_2);
% videoV = cat(3,videoV_1,videoV_2);
% Bfi = [Bfi_1;Bfi_2];
% Vfi = [Vfi_1;Vfi_2];
end