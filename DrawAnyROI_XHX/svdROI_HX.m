function ops = svdROI_HX(ops,im_avg,data)
% ops = svdROI(ops)
%
% Makes average image from movie, promts for drawing ROI
% makes ops.roi field which is applied in SVD (outside ROI set to zero)

subplot(1,2,1);
%imagesc(im_avg_binned);
imagesc(round(im_avg));
%set(gca,'YDir','normal'); %flip image along x axis
colormap(gray);
axis equal off;
draw_roi = true;
count_rois = 0;
while draw_roi
    %caxis([0 std(im_avg_binned(:))]); %this saturates the image. why?
    subplot(1,2,1)
    roiMask = roipoly;
    count_rois = count_rois + 1;
    if count_rois == 1
        roiMaskAll = roiMask;
    elseif count_rois > 1
        roiMaskAll = cat(3, roiMaskAll, roiMask);
    end
        
    hold on
    first_nonzero = find(roiMask > 0,1); %top to bottom, left to right
    [y_nonzero, x_nonzero] = ind2sub([size(data,1), ...
        size(data,2)],first_nonzero); %ind2sub converts linear indices 
    % to subscripts.
    roi_perim = bwtraceboundary(roiMask,[y_nonzero x_nonzero],'N');
    roi = plot(roi_perim(:,2),roi_perim(:,1),'linewidth',2);
    
    keep_roi = input('Keep ROI (y/n)?','s');
    
    if strncmp(keep_roi,'n',1) %this only allows drawing of one roi?
        roiMaskAll(:,:,end) = [];
    else
        % Extract activity traces for each ROI
        offset = 10;
        im_bstack_offset = data + offset;
        %nan zero
        %.*
        reg_stack = reshape(im_bstack_offset,540*640,size(im_bstack_offset,3));
        mask = reshape(roiMask,540*640,1);
        % activity = im_bstack_offset .* roiMask;
        activity = mean(reg_stack(mask,:))-offset;
        % Calculate dF/F
        f0 = min(activity);
        dff = (activity-f0) / f0;
        subplot(1,2,2);
        plot(dff) % plot the activity traces
        hold on
        if count_rois == 1
            activityAll = activity;
            dffAll = dff;
        else
            activityAll = cat(3,activityAll, activity);
            dffAll = cat(3,dffAll,dff);
        end

        % fit Gaussian mixture model? WHY do this?
    end
    
    more_roi = input('Draw more ROI (y/n)?','s');
    if strncmp(more_roi,'y',1)
        draw_roi = true;
    elseif strncmp(more_roi, 'n', 1)
        draw_roi = false;
        hold off;
        close();
    end
    
end

ops.roi = roiMaskAll;
ops.dff = dffAll;

