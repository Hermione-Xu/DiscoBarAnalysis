%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% created by Hemanth Mohan
% hemanth.mohan@duke.edu
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close; clc
if isempty(gcp('nocreate')) == 1
    parpool('local',8); % Start parallel pool (parpool)
end
[fname fpath] = uigetfile('*.tif');
listing_tif = dir([fpath '\*.tif']);
fname_tif_all = natsortfiles({listing_tif.name}');
%%
isOdd = rem(length(fname_tif_all),2);
if isOdd
    fidx_1 = -1;
    fidx_2 = 0;
    iCount = 0;
    %% perform dff of the initial files
    for ii = 1:floor(length(fname_tif_all)/2)
        %% extract file names
        
        fidx_1 = fidx_1+2;
        fidx_2 = fidx_2+2;
        
        cur_fname_1 = fname_tif_all{fidx_1};
        vfile_1 = fullfile(fpath,cur_fname_1)
        
        cur_fname_2 = fname_tif_all{fidx_2};
        vfile_2 = fullfile(fpath,cur_fname_2)
        
        %% generate crop coordinates
        
        if fidx_1==1
            coorfile = [cur_fname_1(1:end-4) '_coor.mat'];
            
            if exist(fullfile(fpath,coorfile))
                load(fullfile(fpath,coorfile));
                disp('Loading PreExisting Coordinate Location for cropping!!')
            else
                [cpos, refimg] = MakeCoorFile_XHX(fpath,vfile_1,coorfile);
            end
        end
        %% split double videos and combine
        disp(' extracting videos...')
        tic
        [videoB videoV Bfi Vfi] = SplitVideoDouble_XHX(vfile_1,vfile_2,cpos); %% Bfi and Vfi are frame indices of blue and violet frames
        toc
        VidSzB = size(videoB);
        VidSzV = size(videoV);
        
        %% reshape videos
        vB = single(reshape(videoB,(size(videoB,1))*size(videoB,2),size(videoB,3)));
        vV = single(reshape(videoV,size(videoV,1)*size(videoV,2),size(videoV,3)));
        %     clearvars -except vB vV VidSzB VidSzV fpath cur_fname_1 cur_fname_2 ii
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
        % clearvars -except vBdt vVdt VidSzV VidSzB fpath cur_fname_1 cur_fname_2 %%%%% activate if matlab crashes
        %% perform df_f
        disp(' performing df/f...')
        tic
        [dffV] = MakeDff_XHX(vBdt,vVdt,VidSzB);
        toc
        %% Saving DffV
        iCount = iCount+1; %%% track the the file counts
        disp(' saving signal ...')
        SaveDff_XHX(dffV,fpath,cur_fname_1,cur_fname_2,iCount);
        %%
    end
    
    %% perform dff of the final odd file
    %% extract file names
    fidx = fidx_2+1;
    cur_fname = fname_tif_all{fidx};
    vfile = fullfile(fpath,cur_fname)
    %% split videos
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
    %% reshape videos
    vB = single(reshape(videoB,(size(videoB,1))*size(videoB,2),size(videoB,3)));
    vV = single(reshape(videoV,size(videoV,1)*size(videoV,2),size(videoV,3)));
    %     clearvars -except vB vV VidSzB VidSzV fpath cur_fname_1 cur_fname_2 ii
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
    % clearvars -except vBdt vVdt VidSzV VidSzB fpath cur_fname_1 cur_fname_2 %%%%% activate if matlab crashes
    %% perform df_f
    disp(' performing df/f...')
    tic
    [dffV] = MakeDff_XHX(vBdt,vVdt,VidSzB);
    toc
    %% Saving DffV
    iCount = iCount+1; %%% track the the file counts
    disp(' saving signal ...')
    SaveDff_XHX(dffV,fpath,cur_fname,[],iCount);
    %%
    clearvars vBdt vVdt vB vV dffV videoB  videoV
else
    %%
    fidx_1 = -1;
    fidx_2 = 0;
    iCount = 0;
    %% perform dff of the initial files
    for ii = 1:floor(length(fname_tif_all)/2)
        %% extract file names
        
        fidx_1 = fidx_1+2;
        fidx_2 = fidx_2+2;
        
        cur_fname_1 = fname_tif_all{fidx_1};
        vfile_1 = fullfile(fpath,cur_fname_1)
        
        cur_fname_2 = fname_tif_all{fidx_2};
        vfile_2 = fullfile(fpath,cur_fname_2)
        
        %% generate crop coordinates
        
        if fidx_1==1
            coorfile = [cur_fname_1(1:end-4) '_coor.mat'];
            
            if exist(fullfile(fpath,coorfile))
                load(fullfile(fpath,coorfile));
                disp('Loading PreExisting Coordinate Location for cropping!!')
            else
                [cpos, refimg] = MakeCoorFile_XHX(fpath,vfile_1,coorfile);
            end
        end
        %% split double videos and combine
        disp(' extracting videos...')
        tic
        [videoB videoV Bfi Vfi] = SplitVideoDouble_XHX(vfile_1,vfile_2,cpos); %% Bfi and Vfi are frame indices of blue and violet frames
        toc
        VidSzB = size(videoB);
        VidSzV = size(videoV);
        %% remove the extra video B frame
        if VidSzB(3)>VidSzV(3)
            videoB(:,:,end)=[];
        end
        VidSzB = size(videoB);
        VidSzV = size(videoV);
        %% reshape videos
        vB = single(reshape(videoB,(size(videoB,1))*size(videoB,2),size(videoB,3)));
        vV = single(reshape(videoV,size(videoV,1)*size(videoV,2),size(videoV,3)));
        clearvars videoB videoV %VidSzB VidSzB
        %     clearvars -except vB vV VidSzB VidSzV fpath cur_fname_1 cur_fname_2 ii
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
        % clearvars -except vBdt vVdt VidSzV VidSzB fpath cur_fname_1 cur_fname_2 %%%%% activate if matlab crashes
        clearvars vB vV pCoeffB s polMuB yFitB pCoeffV polMuV yFitV
        %% perform df_f
        disp(' performing df/f...')
        tic
        [dffV] = MakeDff_XHX(vBdt,vVdt,VidSzB);
        toc
        %% Saving DffV
        iCount = iCount+1; %%% track the the file counts
        disp(' saving signal ...')
        SaveDff_XHX(dffV,fpath,cur_fname_1,cur_fname_2,iCount);
        %%
        clearvars vBdt vVdt dffV
    end
end