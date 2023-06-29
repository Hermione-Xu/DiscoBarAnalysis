vfile = fullfile(fpath,fname);
load(vfile);
dmName = [fname(1:end-10) 'dorsalMap.mat'];
load(fullfile(fpath,dmName));
tform = dorsalMaps.tform;
dmMap = dorsalMaps.edgeOutlineSplit;
dffV= imwarp(dffV,tform,'OutputView',imref2d(size(dorsalMaps.dorsalMapScaled))).*dorsalMaps.maskScaled;