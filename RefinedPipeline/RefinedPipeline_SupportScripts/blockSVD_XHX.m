function [bV, bU, blockInd, bAvg, vAvg] = blockSVD_XHX(ops)

if isfield(ops,'frames_per_stack')
    nFrames = ops.frames_per_stack;
else
    nFrames = [];
end

blocknum = ops.blocknum;
overlap = ops.overlap;

disp('======================')
disp(ops.fpath)

%% split double videos and combine
disp('Extracting videos and splitting channels...')

% Bfi and Vfi are frame indices of blue and violet frames
[videoB, videoV, Bfi, Vfi] = SplitVideoDouble_XHX_PG(ops.vfile,ops.refimg,nFrames); 

[videoB, videoV, Bfi, Vfi] = SplitVideoDouble_XHX(ops); 
VidSzB = size(videoB);
VidSzV = size(videoV);

%% Get reference images for motion correction
bRef = fft2(median(videoB,3)); % blue reference for alignment
save([ops.fpath 'blueRef.mat'],'bRef');
vRef = fft2(median(videoV,3));
save([ops.fpath 'violetRef.mat'],'vRef');

if ops.useGPU
    bRef = gpuArray(bRef);
    vRef = gpuArray(vRef);
end
% bRef = gather(bRef);
% vRef = gather(vRef);
%% Get index for individual blocks. All of these are preparing for block SVD.

% This is an "image" with corresponding indices
indImg = reshape(1:numel(bRef), size(bRef)); 
% size of each blcok
blockSize = ceil((size(bRef)+repmat(sqrt(blocknum)*overlap, 1, 2))/sqrt(blocknum)); 
blockInd = cell(1,blocknum); % empty cell. place holder.

count = 0;
colSteps = (0:blockSize(1)-overlap:size(bRef,1)) + 1; % Step size for columns
rowSteps = (0:blockSize(2)-overlap:size(bRef,2)) + 1;
% Generate indices for each block and store in blockInd
for iRows = 1:sqrt(blocknum)
    for iCols = 1:sqrt(blocknum)
        count = count+1;
        % Get current block and save index as a vector
        colInd = colSteps(iCols) : colSteps(iCols)+blockSize(1)-1;
        rowInd = rowSteps(iRows) : rowSteps(iRows)+blockSize(2)-1;

        colInd(colInd>size(bRef,1)) = []; % Remove extra space
        rowInd(rowInd>size(bRef,2)) = [];

        cBlock = indImg(colInd,rowInd);
        blockInd{count} = cBlock(:);
    end
end
% blockInd = blockInd(~cellfun('isempty',blockInd));
save([ops.fpath 'blockInd.mat'],'blockInd');

%% Perform image alignment (motion correction) for separate channels and
%  collect data in mov matrix.
% fileCount = 1;
% bAvg = zeros([VidSzB(1), VidSzB(2)],'uint16');
% vAvg = zeros([VidSzV(1), VidSzV(2)],'uint16');

% frameCount = NaN(2,fileCount,'single'); %??????????????????
% stimTim = Nan(1,fileCount,'single'); %?????????????????????
bBlocks = zeros(1,blocknum);
vBlocks = zeros(1,blocknum);

% for iTrials = 1:fileCount
%     frameCount(1,iTrials) = trials(iTrials); % trial number
%     frameCount(2,iTrials) = VidSzB(3); % Number of frames
% end

% Check if numbers of the blue frames and violet frames are the same
if VidSzB(3) > VidSzV(3)
    videoB(:,:,end) = [];
    VidSzB = size(videoB);
end

% Can't use because gpuDevice doesn't have enough memory space.
% if ops.useGPU
%     videoB = gpuArray(videoB);
%     % videoV = gpuArray(videoV);
% end

% Perform image alignment for both channels
for iFrames = 1:VidSzB(3)
    [~,temp] = dftregistration(bRef, fft2(videoB(:,:,iFrames)), 10);
    videoB(:,:,iFrames) = abs(ifft2(temp));

    [~,temp] = dftregistration(vRef, fft2(videoV(:,:,iFrames)), 10);
    videoV(:,:,iFrames) = abs(ifft2(temp));
    if rem(iFrames,200) == 0
        disp(iFrames);
    end
end
clearvars temp bRef vRef
% videoB = gather(videoB);
% videoV = gather(videoV);
% atest = videoB(:,:,1); 
% atest2 = mat2gray(atest); % need to do normalization to show image

% Calculate the average of baseline. How do we decide on the baseline?
bAvg = mean(videoB(:,:,1:ops.baselineFrames),3);
vAvg = mean(videoV(:,:,1:ops.baselineFrames),3);
% imshow(mat2gray(bAvg))

videoB = reshape(videoB, [], VidSzB(3));
videoV = reshape(videoV, [], VidSzV(3));

for iBlocks = 1:blocknum
    % if iTrials == 1
    % Need to create the folder first
    bBlocks(iBlocks) = fopen([ops.fpath 'blockData' filesep 'bBlock' num2str(iBlocks) '.dat'], 'W'); %or 'Wb'
    vBlocks(iBlocks) = fopen([ops.fpath 'blockData' filesep 'vBlock' num2str(iBlocks) '.dat'], 'W');
    % end

    bBlock = videoB(blockInd{iBlocks},:);
    vBlock = videoV(blockInd{iBlocks},:);
    fwrite(bBlocks(iBlocks), bBlock, 'uint16'); % write data to block file
    fwrite(vBlocks(iBlocks), vBlock, 'uint16');

    fclose(bBlocks(iBlocks));
    fclose(vBlocks(iBlocks));

    if rem(iBlocks,50) == 0
        disp(iBlocks)
    end
end

disp('Binary files created!');


%save averages in case you need them later
save([ops.fpath 'blueAvg.mat'],'bAvg');
save([ops.fpath 'hemoAvg.mat'],'vAvg');

%% subtract and divide each block by and compress with SVD
bU = cell(blocknum,1); 
bV = cell(blocknum,1);
for iBlocks = 1 : blocknum
     % load current block
    fID(1) = fopen([ops.fpath 'blockData' filesep 'bBlock' num2str(iBlocks) '.dat'], 'r');
    fID(2) = fopen([ops.fpath 'blockData' filesep 'vBlock' num2str(iBlocks) '.dat'], 'r');

    allBlock = NaN(size(blockInd{iBlocks},1)* VidSzB(3), 2, 'single');
    allBlock(:,1) = fread(fID(1), 'uint16'); fclose(fID(1));
    allBlock(:,2) = fread(fID(2), 'uint16'); fclose(fID(2));

    % delete([ops.fpath 'blockData' filesep 'bBlock' num2str(iBlocks) '.dat']);
    % delete([ops.fpath 'blockData' filesep 'vBlock' num2str(iBlocks) '.dat']);

    % compute dF/F
    allBlock = reshape(allBlock, size(blockInd{iBlocks},1), VidSzB(3), 2);
    allBlock(:,:,1) = bsxfun(@minus, allBlock(:,:,1), bAvg(blockInd{iBlocks}));
    allBlock(:,:,1) = bsxfun(@rdivide, allBlock(:,:,1), bAvg(blockInd{iBlocks}));
    allBlock(:,:,2) = bsxfun(@minus, allBlock(:,:,2), vAvg(blockInd{iBlocks}));
    allBlock(:,:,2) = bsxfun(@rdivide, allBlock(:,:,2), vAvg(blockInd{iBlocks}));

    % run SVD on current block
    allBlock = reshape(allBlock,size(allBlock,1),[])'; %combine channels and transpose (this is faster if there are more frames as pixels)
    [bV{iBlocks}, s, bU{iBlocks}] = fsvd(allBlock,ops.blockDims); %U and V are flipped here because we transpoed the input.
    bV{iBlocks} = gather(s * bV{iBlocks}'); %multiply S into V, so only U and V from here on
    bU{iBlocks} = gather(bU{iBlocks});
    clear allBlock
end

% save blockwise SVD data from both channels
save([ops.fpath 'bV.mat'], 'bU', 'bV', 'blockInd', 'ops', '-v7.3');
disp('Blockwise SVD complete');