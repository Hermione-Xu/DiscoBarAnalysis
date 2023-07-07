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

figure;
for i = 1:5
    refPix = MyPixels(i,1)*FrameSize(1) + MyPixels(i,2);
    for j = 1:nPixels
        R = corrcoef(ch_470(:,j),ch_470(:,refPix));
        C(j,1) = R(1,2);
    end
    subplot(2,3,i);
    imagesc(reshape(C,FrameSize(1),FrameSize(2)));
    colormap(brewermap([],'*RdBu'));
    hold on
    plot(MyPixels(i,1),MyPixels(i,2),'*k');
end

figure;
for i = 1:5
    subplot(5,1,i); hold on
    plot(squeeze(ch_470(MyPixels(i,2),MyPixels(i,1),:)),'r');
    set(gca,'XLim',36000 + [0 30*60]);
end
