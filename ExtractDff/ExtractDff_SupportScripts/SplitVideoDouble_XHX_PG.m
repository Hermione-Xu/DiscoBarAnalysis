function [videoB, videoV, Bfi, Vfi] = SplitVideoDouble_XHX_PG(vfiles,refimg,nFrames)
%% Created by Hemanth Mohan, modified by Hermione Xu.
%%

if nargin<3
    nFrames = [];
end

vfile_1 = vfiles{1}; % first stack
totalframes = nFrames;
if size(vfiles,2) > 1
    vfile_2 = vfiles{2}; % second stack, if processing in groups of two
    totalframes = totalframes + nFrames;
else
    vfile_2 = [];
end

%pos = ops.pos;


% tiff_info_1 = imfinfo(vfile_1);
% tiff_info_2 = imfinfo(vfile_2);

%totalframes = size(tiff_info_1,1) + size(tiff_info_2,1);

% initialize cropped stacks for each channel
BlueFrames = ceil(totalframes/2);
VioletFrames = floor(totalframes/2); % blue is saved first - so if there are odd number of frames - it will always be more blue than violet
videoB = zeros(size(refimg,1),size(refimg,2),BlueFrames); 
videoV = zeros(size(refimg,1),size(refimg,2),VioletFrames);

Bfi = zeros(1,BlueFrames);
Vfi = zeros(1,VioletFrames);

tic
% read the stack
stackdone = 0; frames_read = 0;
while ~stackdone
    myframe = imread(vfile_1,frames_read+1);
    
    if rem(frames_read,2) == 0 % violet frame
    else
    end
end

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