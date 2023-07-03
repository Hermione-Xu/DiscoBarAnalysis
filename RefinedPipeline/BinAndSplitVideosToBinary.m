% data paths for the raw tiffs
TiffPath = '/mnt/storage/Widefield/HX3/20230406_r0';
listing_tif = dir(fullfile(TiffPath,'*.tif'));
fname_tif_all = arrayfun(@(x) x.name, listing_tif, 'UniformOutput', false); % no need for natsortfiles
nStacks = length(fname_tif_all);

% for binning - BinFactor
BinBy = 4;

% paths for saving the binary files
BinaryPath  = regexprep(TiffPath,'storage','data');
BlueDat     = fullfile(BinaryPath,'470_frames.dat');
VioletDat   = fullfile(BinaryPath,'407_frames.dat');
Bfid        = fopen(BlueDat, 'w');
Vfid        = fopen(VioletDat, 'w');

% for saving frame timestamps
BlueTS      = fullfile(BinaryPath,'470_timestamps.dat');
VioletTS    = fullfile(BinaryPath,'407_timestamps.dat');
Bfid_ts     = fopen(BlueTS, 'w');
Vfid_ts     = fopen(VioletTS, 'w');

% variable initializations
TimeStamps = [];
warning('off','all');
verbose = 1;
extraverbose = 0;

for i = 1:nStacks % for every raw tiff stack
    
    thisFile = fullfile(TiffPath,fname_tif_all{i});
    
    if verbose
        fprintf(1, 'loading file: %s (%d of %d)\n', thisFile, i, nStacks);
    end
    
    % load the stack
    tic % 16.7 3.9
    clear tsStack t TimeStamps thisFN thisTS BinnedStack blue_indices violet_indices
    tsStack = loadTiffStack(thisFile, 'tiffobj', extraverbose);
    toc
    
    tic % 0.03 0.01
    % get timestamps
    TimeStamps = squeeze(tsStack(1,1:14,:));
    [thisFN, thisTS] = timeFromPCOBinaryMulti(TimeStamps); % [frame_numbers frame_timestamps]
    thisTS = thisTS*24*3600; % convert to seconds from days
    if i == 1
        firstTS = thisTS(1); % to get relative timestamps
    end
    %toc
    
    %tic % 6.83
    BinnedStack = zeros(size(tsStack,1)/BinBy, size(tsStack,2)/BinBy, size(tsStack,3));
    for f = 1:size(tsStack,3)
        BinnedStack(:,:,f) = binImage_ns(squeeze(tsStack(:,:,f)),BinBy);
    end
    %toc
    
    if mod(thisFN(1),2) % first frame is a blue Frame
        blue_indices = 1:2:size(tsStack,3);
        violet_indices = 2:2:size(tsStack,3);
    else
        blue_indices = 2:2:size(tsStack,3);
        violet_indices = 1:2:size(tsStack,3);
    end
    
    %tic % 0.15
    % write frames
    fwrite(Bfid, uint16(BinnedStack(:,:,blue_indices)), 'uint16');
    fwrite(Vfid, uint16(BinnedStack(:,:,violet_indices)), 'uint16');
    %toc
    
    %tic % 0.001
    % write the timestamps
    fwrite(Bfid_ts, [thisFN(blue_indices)' ...
                        thisTS(blue_indices)' ...
                        thisTS(blue_indices)'-firstTS ...
                        i*ones(numel(blue_indices),1) ], 'double');
    fwrite(Vfid_ts, [thisFN(violet_indices)' ...
                        thisTS(violet_indices)' ...
                        thisTS(violet_indices)'-firstTS ...
                        i*ones(numel(violet_indices),1) ], 'double');
    toc
        
end

fclose(Bfid);
fclose(Vfid);
fclose(Bfid_ts);
fclose(Bfid_ts);
