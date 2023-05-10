%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% created by Hemanth Mohan: hemanth.mohan@duke.edu
% Modified by Hermione Xu: xinmeng.xu@duke.edu
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close; clc
if isempty(gcp('nocreate')) == 1
    parpool('local',8); % Start parallel pool (parpool)
end
[ops.fname, ops.fpath] = uigetfile('*.tif');
listing_tif = dir([ops.fpath '\*.tif']);
fname_tif_all = natsortfiles({listing_tif.name}');

timestamps_legend = ['Frame Number', 'Date (yyyymmdd)', 'Time (hhmmssxxxxxx'];
timestamps = zeros(6194, 3, ceil(size(fname_tif_all,1)/2));
% countframe = 1;

ops.verbose = true;
ops.useGPU = true;
ops.blocknum = 49; %nr of blocks for svd
ops.overlap = 20; % An integer smaller than sqrt(blocknum)
ops.baselineFrames = 60; % How do we decide on the baseline? For now, make it the first 60 frames.
ops.blockDims = 25; %number of dimensions from SVD per block
ops.dimCnt = 200; % number of components in the final dataset
ops.frameRate = 30; % Frame rate of individual channels
%%
isOdd = rem(length(fname_tif_all),2);
if isOdd
    fidx_1 = -1; % file index
    fidx_2 = 0;
    iCount = 0;
    %% perform dff of the initial files
    for ii = 1:floor(length(fname_tif_all)/2)
        %% Update file names      
        fidx_1 = fidx_1+2;
        fidx_2 = fidx_2+2;
        cur_fname_1 = fname_tif_all{fidx_1};
        ops.vfile_1 = fullfile(ops.fpath,cur_fname_1);
        cur_fname_2 = fname_tif_all{fidx_2};
        ops.vfile_2 = fullfile(ops.fpath,cur_fname_2)
        %% Extract time stamp
        disp('Extracting time stamps...')
        tic
        timestamps(:,:,ii) = extract_time_stamps_XHX(ops); %only takes 6194x3 size matrix. make it a cell array?
        % timestamps(countframe:countframe+size(temp_stamp,1)-1,:) = temp_stamp;
        % countframe = countframe + size(temp_stamp,1); % Update counter
        % clearvars temp_stamp
        toc
        %% generate crop coordinates
        if fidx_1==1
            ops = get_coordinates_XHX(ops);
        end

        

        % blockSVD function splits channels, does motion correction, df/f,
        % and block SVD (separates the imaging frames into smaller blocks 
        % and performs linear dimensionality using randomized SVD. This
        % step returns block-wise data 'bV' and 'bU'
        [bV, bU, blockInd, bAvg, vAvg] = blockSVD_XHX(ops);

        %% Create whole-frame components
        % merge dimensions if bV is in dims x trials x frames format
        if iscell(bV)
            bV = cat(1,bV{:});
            if length(size(bV)) == 3
                bV = reshape(bV,size(bV,1), []);
            end
        end

        % testbU=cat(1,bU{:});

        % combine all blue blocks and run a second SVD
        [nU, s, nV] = fsvd(bV,ops.dimCnt); %combine all blocks in a second SVD
        nV = s * nV'; %multiply S into V
        Sv = diag(s); %keep eigenvalues

        %% Sidenote. Try converting NaN in bU to 0
        % testbU = bU;
        for ibU = 1:ops.blocknum
            bU{ibU}(isnan(bU{ibU})) = 0;
        end
        %% combine blocks back into combined components
        [~, cellSize] = cellfun(@size,bU,'UniformOutput',false);
        % [~, testcellSize] = cellfun(@size,testbU,'UniformOutput',false);
        cellSize = cat(2,cellSize{:}); % get number of components in each block
        % testcellSize = cat(2,testcellSize{:});

        % rebuild block-wise U from individual blocks
        blockU = zeros(numel(bAvg), sum(cellSize),'double');
        % blockU = zeros(numel(bAvg), sum(testcellSize),'double');
        edgeNorm = zeros(numel(bAvg),1,'single');
        Cnt = 0;
        for iBlocks = 1 : length(bU)
            cIdx = Cnt + (1 : size(bU{iBlocks},2));
            blockU(blockInd{iBlocks}, cIdx) = blockU(blockInd{iBlocks}, cIdx) + bU{iBlocks};
            edgeNorm(blockInd{iBlocks}) = edgeNorm(blockInd{iBlocks}) + 1;
            Cnt = Cnt + size(bU{iBlocks},2);
        end
        % for iBlocks = 1 : length(testbU)
        %     cIdx = Cnt + (1 : size(testbU{iBlocks},2));
        %     blockU(blockInd{iBlocks}, cIdx) = blockU(blockInd{iBlocks}, cIdx) + testbU{iBlocks};
        %     edgeNorm(blockInd{iBlocks}) = edgeNorm(blockInd{iBlocks}) + 1;
        %     Cnt = Cnt + size(testbU{iBlocks},2);
        % end
        edgeNorm(edgeNorm == 0) = 1; %remove zeros to avoid NaNs in blockU

        blockU = bsxfun(@rdivide, blockU, edgeNorm);

        % project block U on framewide spatial components
        dSize = size(blockU);
        blockU = reshape(blockU,[],dSize(end)); %make sure blockU is in pixels x componens
        U = blockU * nU; %make new U with framewide components
        disp('Second SVD complete'); 

        %% do hemodynamic correction
        nV = reshape(nV, size(nV,1), [], 2); % split channels
        U = reshape(U,size(bAvg,1),size(bAvg,2),[]); %reshape to frame format

        % save([ops.fpath 'U.mat'],'U');
        % save([ops.fpath 'nV.mat'],'nV');
        % save([ops.fpath 'ops.mat'], 'ops');

        % Load U and nV
        % nV = load(fullfile('D:\test\nV.mat'));
        % U = load(fullfile('D:\test\U.mat'));
        % pos = load(fullfile('D:\test\ops.mat'));
        
        % do hemodynamic correction
        [Vc, regC, T, hemoVar] = SvdHemoCorrect(U, nV(:,:,1), nV(:,:,2), ops.frameRate, 3097, 10, true);
        % [Vc, regC, T, hemoVar] = SvdHemoCorrect(U, nV(:,:,1), nV(:,:,2), ops.frameRate, frameCnt(2,:), 10, true);

        

        %% %%%%%%%%%% polynomial detrending of signals %%%%%%%%%%%%%%%
        % Not very ideal? Skip this and try SVD alone?
        % reshape videos
        vB = single(reshape(videoB,(size(videoB,1))*size(videoB,2),size(videoB,3)));
        vV = single(reshape(videoV,size(videoV,1)*size(videoV,2),size(videoV,3)));
        %     clearvars -except vB vV VidSzB VidSzV fpath cur_fname_1 cur_fname_2 ii
        % disp('Detrending singal...')
        % vBdt = single([]);
        % vVdt = single([]);
        % polOrder = 7; %%% order of the polynomial. Default = 7
        % x = [1:size(vB,2)]'; % create a 3097x1 array
        % 
        % parfor ii = 1:size(vB,1)
        %     [pCoeffB,s,polMuB] = polyfit(x,vB(ii,:)',polOrder);
        %     yFitB = polyval(pCoeffB,x,[],polMuB);
        %     vBdt(ii,:) = single(vB(ii,:) - yFitB')+ mean(yFitB); %%%%%%%% detrended vB
        % 
        %     [pCoeffV,~,polMuV] = polyfit(x,vV(ii,:)',polOrder);
        %     yFitV = polyval(pCoeffV,x,[],polMuV);
        %     vVdt(ii,:) = single(vV(ii,:) - yFitV') + mean(yFitV); %%%%%%%% detrended vV
        % end
        % clearvars -except vBdt vVdt VidSzV VidSzB fpath cur_fname_1 cur_fname_2 %%%%% activate if matlab crashes
        %% Motion correction

        %% Hemodynamic correction
        
        %% Perform SVD
        ops.vB = vB;
        ops.vV = vV;
        ops.nAvgFramesSVD = 600;
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