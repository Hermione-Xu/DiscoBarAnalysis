function [] = LoadBinaryStacks(BinaryPath)

% get frame sizes and binning factor
S = load(fullfile(BinaryPath,'params.mat'));
%FrameSize = (settings(1,1:2))/settings(3);
FrameSize   = S.TS.settings(1:2)/S.TS.settings(3);
nBlue       = S.TS.settings(4);
nViolet     = S.TS.settings(5);

% read the frame timestamps and counts

pixel_offset = FrameSize(1)*FrameSize(2)*8; %2 bytes/unit16
whichpixel = 6750;
% Read the data
parfor ii = 1:nBlue
    fid = fopen( fullfile(BinaryPath,'470_frames.dat'), 'rb' );
    % Get to the correct spot in the file:
    offset_bytes = whichpixel; % + ((ii-1) * pixel_offset);
    fseek( fid, offset_bytes, 'bof' );
    % read a column
    y(:,ii) = fread(fid, 1000, 'uint16', 'skip', pixel_offset);
    fclose( fid );
end


end

