function PlayDff(dffV,scl,cmap)
% enter cmap as eg PlayDff(dffV,scl,'cmap3')
if nargin == 1
    scl = 0.03;
    cmap = 'cmap2';
elseif nargin == 2
    cmap = 'cmap2';
end

if length(scl) == 1
    vScl = [-scl scl];
else
    vScl = scl;
end
try
    load(['F:\Hemanth_CSHL\WideField\Data\' cmap '.mat']);
    cmapdata = eval(cmap);
    
catch
    cmapdata = cmap;
end

dffV_sm =  smoothdata(dffV,3,'movmean',5); %%% Smoothing Vdata across time
fh = figure;
for i = 1:size(dffV_sm,3)
    figure(fh);
    imagesc(imgaussfilt(dffV_sm(:,:,i),2),vScl)
    text(3,3,num2str(i),'color','w')
    axis image
    colormap(cmapdata)
    colorbar
    pause(0.034)
end
end



