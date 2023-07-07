function [ch_470] = ViewProcessedBinaryStack(BinaryPath)

% get frame sizes and binning factor
S = load(fullfile(BinaryPath,'params.mat'));
FrameSize   = S.TS.settings(1:2)/S.TS.settings(3)/2; % after 2x2 re-binning
FrameSize   = ceil(FrameSize);
nPixels     = FrameSize(1)*FrameSize(2);
nBlue       = S.TS.settings(4);
nViolet     = S.TS.settings(5);
nFrames     = min(nBlue,nViolet);
clear S

tic
% loading the whole stack in one go
fid = fopen(fullfile(BinaryPath,'470_processed_frames.dat'));
ch_470 = fread(fid,inf,'single');
fclose(fid);
ch_470 = reshape(ch_470,FrameSize(1),FrameSize(2),nFrames);




