BinaryPath = '/mnt/data/Widefield/HX3/20230505_r0';
[ch_470] = ViewProcessedBinaryStack(BinaryPath);
stackdims = size(ch_470);
imagesc(mean(ch_470,3));
colormap_RedWhiteBlue;
hold on
    
WhichROIs = [];
for x = 24:10:48
    y = 18;
    WhichROIs = vertcat(WhichROIs,[x y]);
    %plot(x,y,'ok');
end
for x = 17:10:58
    y = 26;
    WhichROIs = vertcat(WhichROIs,[x y]);
    %plot(x,y,'ok');
end
x = 68; y = 28;
WhichROIs = vertcat(WhichROIs,[x y]);
%plot(x,y,'ok');
for x = 20:20:40
    y = 35;
    WhichROIs = vertcat(WhichROIs,[x y]);
    %plot(x,y,'ok');
end
for x = 16:10:58
    y = 44;
    WhichROIs = vertcat(WhichROIs,[x y]);
    %plot(x,y,'ok');
end
x = 68; y = 37;
WhichROIs = vertcat(WhichROIs,[x y]);
%plot(x,y,'ok');
for x = 23:10:48
    y = 52;
    WhichROIs = vertcat(WhichROIs,[x y]);
    %plot(x,y,'ok');
end

WhichROIs = fliplr(WhichROIs);
% check locations
for i = 1:length(WhichROIs)
    plot(WhichROIs(i,2),WhichROIs(i,1),'.k');
end

%% get 2D correlations
nPix = stackdims(1)*stackdims(2);
ch_470_lin = reshape(ch_470,nPix,stackdims(3))';
for i = 1:length(WhichROIs)
%     refPix(:,i) = squeeze(ch_470(WhichROIs(i,1),WhichROIs(i,2),:));
%     for j = 1:nPix
%         R = corrcoef(ch_470_lin(:,j),refPix(:,i));
%         C(j,i) = R(1,2);
%     end
    subplot(4,5,i);
    imagesc(reshape(C(:,i),stackdims(1),stackdims(2)));
    colormap(brewermap([],'*RdBu'));
    hold on
    plot(WhichROIs(i,2),WhichROIs(i,1),'sk');
    rectangle('Position',[-2 + fliplr(WhichROIs(i,:)), 4, 4]);
    set(gca,'TickDir','out','XTick',[],'YTick',[]);
end

%%
save(fullfile(BinaryPath,'selectedROIs.mat'),'WhichROIs','refPix','C','stackdims');


   

