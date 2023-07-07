function [] = HemoCorrectAndResaveBinary(BinaryPath,verbose)

if nargin<2
    verbose = 1;
end
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
clear S

if verbose
    fprintf(1, 'loading and detrending blue frames\n');
    tic
end
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

if verbose
    toc
    fprintf(1, 'loading and detrending violet frames\n');
    tic
end

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

if verbose
    toc
    fprintf(1, 'performing hemodynamic correction\n');
    tic
end

for i = 1:nPixels
    ch_407(:,i) = mean([ch_407(:,i) [ch_407(1,i); ch_407(1:end-1,i)] ],2);
    ch_470(:,i) = ch_470(:,i)./ch_407(:,i);
    ch_470(:,i) = ch_470(:,i)/mean(ch_470(:,i));
    
    % normalize by sd?
    %ch_470(:,i) = (ch_470(:,i)-mean(ch_470(:,i)))/std(ch_470(:,i));
    ch_470(:,i) = ch_470(:,i)/std(ch_470(:,i));
end

if verbose
    toc
    fprintf(1, 'binning 2x2 and resaving\n');
    tic
end

clear ch_407

% bin 2x2
ch_470 = reshape(ch_470',FrameSize(1),FrameSize(2),nFrames); % [X x Y x frames]
ch_470_binned = BinImage2Dconv(ch_470,2);
clear ch_470

% resave as binary
if verbose
    toc
    fprintf(1, 'saving processed binary file\n');
    tic
end

HemoDat     = fullfile(BinaryPath,'470_processed_frames.dat');
Hfid        = fopen(HemoDat, 'w');
fwrite(Hfid, single(ch_470_binned), 'single');
fclose(Hfid);

if verbose
    toc
end

% change permissions
command = ['chmod -R 777 ',BinaryPath];
system(command);

end


