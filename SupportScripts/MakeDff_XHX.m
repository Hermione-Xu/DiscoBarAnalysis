function [videoBc_norm] = MakeDff_XHX(vB,vV,VidSz)
vsize1 = [round(size(vB,1)/2) size(vB,2)]; 
vsize2 = [(vsize1(1)+1) size(vB,2)]; 
TrB_nm= (vB - median(vB,2))./median(vB,2);
TrV_nm= (vV - median(vV,2))./median(vV,2);

parfor ii=1:size(vB,1)
    TrRcoef = [ones(size(TrV_nm(ii,:),2),1) movmean(TrV_nm(ii,:),10)'] \ TrB_nm(ii,:)'; %% Signal B is regressed with moving averaged for 10 frames(340ms) signal V
    Tr_corrected = TrB_nm(ii,:)-([ones(size(TrV_nm(ii,:),2),1) (TrV_nm(ii,:))']*TrRcoef)';
    videoBc_norm(ii,:) = Tr_corrected;
end
videoBc_norm = reshape(videoBc_norm, VidSz(1),  VidSz(2),  VidSz(3));
clearvars -except videoBc_norm
end
