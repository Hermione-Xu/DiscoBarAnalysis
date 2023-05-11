% add TIFFStack
addpath(genpath('/opt/TIFFStack'));

% select one imaging file and then get all other .tif files in the folder
MyFavoriteFile = '/mnt/albeanu_lab/priyanka/Widefield/HX3/20230406_r0/HX3@0001.tif';
[ops.fname, ops.fpath] = uigetfile('*@*.tif','Select file',MyFavoriteFile);
listing_tif = dir([ops.fpath,filesep,'*@*.tif']);
fname_tif_all = arrayfun(@(x) x.name, listing_tif, 'UniformOutput', false); % no need for natsortfiles
nStacks = length(fname_tif_all);

% get an ROI
ops = get_coordinates_XHX(ops);
MyTraces = []; TimeStamps = [];
for i = 1:nStacks
    tsStack = TIFFStack(fullfile(ops.fpath,fname_tif_all{i}));
    TimeStamps = 
    %MyTraces = MyTraces()
    
end
