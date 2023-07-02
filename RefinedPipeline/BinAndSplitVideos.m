% add TIFFStack
addpath(genpath('/opt/TIFFStack'));

% data paths
DataPath = '/mnt/storage/Widefield/HX3/20230406_r0';
listing_tif = dir(fullfile(DataPath,'*.tif'));
fname_tif_all = arrayfun(@(x) x.name, listing_tif, 'UniformOutput', false); % no need for natsortfiles
nStacks = length(fname_tif_all);

% for binning - BinFactor
BinBy = 4;

if ~exist(fullfile(DataPath,'Binned'))
    mkdir(fullfile(DataPath,'Binned'))
end

% get an ROI
MyTraces = []; TimeStamps = [];

FrameDetails = [];
MyTraces = [];
warning('off','all');

% for binned files
% each binned file can have 3000*16*2 frames at least


for i = 1:nStacks
    disp(i)
    tsStack = TIFFStack(fullfile(DataPath,fname_tif_all{i}));
    
    % get timestamps
    TimeStamps = squeeze(tsStack(1,1:14,:));
    [thisFN, thisTS] = timeFromPCOBinaryMulti(TimeStamps); % [frame_numbers frame_timestamps]
    thisTS = thisTS*24*3600; % convert to seconds from days
    if i == 1
        firstTS = thisTS(1);
    end
    %thisTS = thisTS - firstTS;
    % FrameDetails = [frame# absoluteTS relativeTS Stack#]
    FrameDetails = vertcat(FrameDetails, ...
                        [thisFN' thisTS' (thisTS-firstTS)' (i-1)*ones(numel(thisFN),1)]);
   
   tic
   for f = 1:size(tsStack,3) % every frame
        BinnedStack(:,:) = binImage(squeeze(tsStack(:,:,f)),BinBy);
        
        switch mod(thisFN(f),(3000*16*2))
            case 1
                % start a new blue tiff file
                MyBlueStack = fullfile(DataPath,'Binned',['470_',num2str(ceil(thisFN(f)/(3000*16*2)),'%03.f'),'.tif']);
                imwrite(uint16(BinnedStack),MyBlueStack);
            case 2 
                % start a new violet tiff file
                MyVioletStack = fullfile(DataPath,'Binned',['405_',num2str(ceil(thisFN(f)/(3000*16*2)),'%03.f'),'.tif']);
                imwrite(uint16(BinnedStack),MyVioletStack);
            otherwise
                if mod(thisFN(f),2)
                    % append to the blue stack
                    imwrite(uint16(BinnedStack),MyBlueStack,'WriteMode','append');
                else
                    % append to the violet stack
                    imwrite(uint16(BinnedStack),MyVioletStack,'WriteMode','append');
                end
        end
            
   end
   toc
      
%     MyTraces = cat(3,MyTraces, ...
%         tsStack(401:440,201:240,:) );
end

function [ImageOut] = binImage(ImageIn,BinBy)
    for rows = BinBy:BinBy:size(ImageIn,1)
        for cols = BinBy:BinBy:size(ImageIn,2)
            ImageOut(rows/BinBy, cols/BinBy) = mean(mean(ImageIn(rows-BinBy+1:rows,cols-BinBy+1:cols)));
        end
    end
end