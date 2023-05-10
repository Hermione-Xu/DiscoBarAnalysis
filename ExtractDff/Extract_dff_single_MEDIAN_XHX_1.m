clear; close; clc
if isempty(gcp('nocreate')) == 1
parpool('local',8);
end
[fname fpath] = uigetfile('*.tif');
listing_tif = dir([fpath '\*.tif']);
fname_tif_all = natsortfiles({listing_tif.name}');

%%
fidx = 1; %%% Enter the id of the video for analysis
cur_fname = fname_tif_all{fidx};
vfile = fullfile(fpath,cur_fname);

coorfile = [cur_fname(1:end-4) '_coor.mat'];

if exist(fullfile(fpath,coorfile))
    load(fullfile(fpath,coorfile));
    disp('Loading PreExisting Coordinate Location for cropping!!')
else
[cpos, refimg] = MakeCoorFile_XHX(fpath,vfile,coorfile);
end

%%
disp(' extracting videos...')
tic
[videoB videoV Bfi Vfi] = SplitVideo_XHX(vfile,cpos); %% Bfi and Vfi are frame indices of blue and violet frames
toc
VidSzB = size(videoB);
VidSzV = size(videoV);
%% remove the extra video B frame
if VidSzB(3)>VidSzV(3)
    videoB(:,:,end)=[];
end
%%
vB = single(reshape(videoB,(size(videoB,1))*size(videoB,2),size(videoB,3)));
vV = single(reshape(videoV,size(videoV,1)*size(videoV,2),size(videoV,3)));
clearvars -except vB vV VidSzB VidSzV fpath cur_fname
%% %%%%%%%%%% polynomial detrending of signals %%%%%%%%%%%%%%%
disp(' detrending singal...')
vBdt = single([]);
vVdt = single([]);
polOrder = 7; %%% order of the polynomial. Default = 7
x = [1:size(vB,2)]';

parfor ii = 1:size(vB,1)
[pCoeffB,s,polMuB] = polyfit(x,vB(ii,:)',polOrder);
yFitB = polyval(pCoeffB,x,[],polMuB);
vBdt(ii,:) = single(vB(ii,:) - yFitB')+ mean(yFitB); %%%%%%%% detrended vB

[pCoeffV,~,polMuV] = polyfit(x,vV(ii,:)',polOrder);
yFitV = polyval(pCoeffV,x,[],polMuV);
vVdt(ii,:) = single(vV(ii,:) - yFitV') + mean(yFitV); %%%%%%%% detrended vV
end
% clearvars -except vBdt vVdt VidSzV VidSzB fpath cur_fname %%%%% activate if matlab crashes

%%
disp(' performing df/f...')
tic
[dffV] = MakeDff_XHX(vBdt,vVdt,VidSzV);
% [dffV] = MakeDffGpu_mean(vB,vV,VidSz);
toc

%% Saving DffV
disp(' saving signal ...')
% schoice = input('Do you want to save the video file (1 = yes; 0 = No) : ');
schoice = 1;
if schoice == 1
SaveDff(dffV,fpath,cur_fname);
end

%%
PlayDff(dffV,0.03,'cmap2')
%%%%%%%%%%%%%%%%%%%%% Function %%%%%%%%%%%%%%%%%
% function [videoBc_norm] = MakeDffSpont(vB,vV,VidSz)
% vsize1 = [round(size(vB,1)/2) size(vB,2)]; 
% vsize2 = [(vsize1(1)+1) size(vB,2)]; 
% TrB_nm= (vB - median(vB,2))./median(vB,2);
% TrV_nm= (vV - median(vV,2))./median(vV,2);
% 
% parfor ii=1:size(vB,1)
%     TrRcoef = [ones(size(TrV_nm(ii,:),2),1) movmean(TrV_nm(ii,:),10)'] \ TrB_nm(ii,:)'; %% Signal B is regressed with moving averaged for 10 frames(340ms) signal V
%     Tr_corrected = TrB_nm(ii,:)-([ones(size(TrV_nm(ii,:),2),1) (TrV_nm(ii,:))']*TrRcoef)';
%     videoBc_norm(ii,:) = Tr_corrected;
% end
% videoBc_norm = reshape(videoBc_norm, VidSz(1),  VidSz(2),  VidSz(3));
% clearvars -except videoBc_norm
% end

