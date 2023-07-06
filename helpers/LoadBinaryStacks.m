%function [] = LoadBinaryStacks(BinaryPath)
% settings
% for low-cut filtering
highpassCutoff = 0.00333; % Hz 
Fs = 30; % Hz - sampling rate
[b, a] = butter(2, highpassCutoff/(Fs/2), 'high');

% get frame sizes and binning factor
S = load(fullfile(BinaryPath,'params.mat'));
%FrameSize = (settings(1,1:2))/settings(3);
FrameSize   = S.TS.settings(1:2)/S.TS.settings(3);
nPixels     = FrameSize(1)*FrameSize(2);
nBlue       = S.TS.settings(4);
nViolet     = S.TS.settings(5);
nFrames     = min(nBlue,nViolet);

tic
% loading the whole stack in one go
fid = fopen(fullfile(BinaryPath,'470_frames.dat'));
ch_470 = fread(fid,inf,'uint16');
fclose(fid);
ch_470 = reshape(ch_470,nPixels,nBlue);
% there may be one extra blue frame - remove it
if nBlue~=nFrames
    ch_470(:,nFrames+1:end) = [];
end
toc

tic
fid = fopen(fullfile(BinaryPath,'407_frames.dat'));
ch_407 = fread(fid,inf,'uint16');
fclose(fid);
ch_407 = reshape(ch_407,nPixels,nViolet);
toc

tic
for i = 1:nPixels
    ch_407(i,:) = mean([ch_407(i,:); [ch_407(i,1) ch_407(i,1:end-1)] ],1);
    ch_470(i,:) = ch_470(i,:)./ch_407(i,:);
    ch_470(i,:) = ch_470(i,:)/mean(ch_470(i,:));
    %ch_470(i,:) = filtfilt(b,a,ch_470(i,:));
end
toc

% filter? Z-score?
% filter in chunks of columns
% for c2 = FrameSize(2):FrameSize(2):nPixels
%     c1 = c2 - FrameSize(2) + 1;  
%     ch_407(:,c1:c2) = filtfilt(b,a,ch_407(:,c1:c2));
% end

tic
HemoDat     = fullfile(BinaryPath,'470_corrected_frames.dat');
Hfid        = fopen(HemoDat, 'w');
fwrite(Hfid, single(ch_470), 'single');
fclose(Hfid);
toc



