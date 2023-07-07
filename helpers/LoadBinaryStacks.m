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

ch_470 = ch_470'; % [frames x pixels]
Mean_470 = mean(ch_470,1); % to keep the dc offset
% filter in chunks of columns
for c2 = FrameSize(2):FrameSize(2):nPixels
    c1 = c2 - FrameSize(2) + 1;  
    ch_470(:,c1:c2) = filtfilt(b,a,ch_470(:,c1:c2));
end

ch_470 = ch_470 + Mean_470; % add back the dc offset
toc

tic
fid = fopen(fullfile(BinaryPath,'407_frames.dat'));
ch_407 = fread(fid,inf,'uint16');
fclose(fid);
ch_407 = reshape(ch_407,nPixels,nViolet);

ch_407 = ch_407'; % [frames x pixels]
Mean_407 = mean(ch_407,1); % to keep the dc offset
% filter in chunks of columns
for c2 = FrameSize(2):FrameSize(2):nPixels
    c1 = c2 - FrameSize(2) + 1;  
    ch_407(:,c1:c2) = filtfilt(b,a,ch_407(:,c1:c2));
end

ch_407 = ch_407 + Mean_407; % add back the dc offset
toc

tic
for i = 1:nPixels
    ch_407(:,i) = mean([ch_407(:,i) [ch_407(1,i); ch_407(1:end-1,i)] ],2);
    ch_470(:,i) = ch_470(:,i)./ch_407(:,i);
    ch_470(:,i) = ch_470(:,i)/mean(ch_470(:,i));
    
    % normalize by sd?
    %ch_470(:,i) = (ch_470(:,i)-mean(ch_470(:,i)))/std(ch_470(:,i));
    ch_470(:,i) = ch_470(:,i)/std(ch_470(:,i));
end
toc

% bin 2x2

% resave as binary? or tiff? or both?

refPix = 4763; % 35, 38; 6430;
refPix = 135*135 + 55;
refPix = 135*135 + 85;
for i = 1:nPixels
    R = corrcoef(ch_470(:,i),ch_470(:,refPix));
    C(i,1) = R(1,2);
end


MyPixels(1,:) = [135 55]; % OB
MyPixels(2,:) = [70 45]; % ?
MyPixels(3,:) = [110 45]; % motor ctx
MyPixels(4,:) = [35 38]; % Visual cortex?
MyPixels(5,:) = [40 55]; % Visual cortex?

figure;
for i = 1:5
    refPix = MyPixels(i,1)*FrameSize(1) + MyPixels(i,2);
    subplot(5,1,i);
    plot(ch_470(:,refPix));
    set(gca,'XLim',36000 + [0 30*60]);
end

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



