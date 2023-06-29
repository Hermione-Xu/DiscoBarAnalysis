% add TIFFStack
addpath(genpath('/opt/TIFFStack'));

% select one imaging file and then get all other .tif files in the folder
DataPath = '/mnt/albeanu_lab/priyanka/Widefield/HX3/20230406_r0';
listing_tif = dir(fullfile(DataPath,'*.tif'));
fname_tif_all = arrayfun(@(x) x.name, listing_tif, 'UniformOutput', false); % no need for natsortfiles
nStacks = length(fname_tif_all);

% get an ROI
%ops = get_coordinates_XHX(ops);
MyTraces = []; TimeStamps = [];

FrameDetails = [];
MyTraces = [];
warning('off','all');

% subselect a 40x40 pixel to extract traces
PixelCorrs_X = repmat((401:440)',1,40);
PixelCorrs_Y = repmat((201:240),40,1);

for i = 1:nStacks
    disp(i)
    tsStack = TIFFStack(fullfile(DataPath,fname_tif_all{i}));
    TimeStamps = squeeze(tsStack(1,1:14,:));
    [thisFN, thisTS] = timeFromPCOBinaryMulti(TimeStamps); % [frame_numbers frame_timestamps]
    thisTS = thisTS*24*3600; % convert to seconds from days
    if i == 1
        firstTS = thisTS(1);
    end
    thisTS = thisTS - firstTS;
    FrameDetails = vertcat(FrameDetails, ...
                        [thisFN' thisTS' (i-1)*ones(numel(thisFN),1)]);
    MyTraces = cat(3,MyTraces, ...
        tsStack(401:440,201:240,:) );
end
