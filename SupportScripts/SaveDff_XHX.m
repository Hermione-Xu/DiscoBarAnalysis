function SaveDff_XHX(dffV,fpath,cur_fname_1,cur_fname_2,iCount)
[animal,sfold] = fileparts(fileparts(fpath));
[~,animal] = fileparts(animal);
spath = fileparts(fileparts(fileparts(fpath)));
Vsavepath = fullfile(spath,['Data_Corrected\' animal '\' sfold]);
sfname = [cur_fname_1(1:end-4) '_' cur_fname_2(1:end-4) '_dffV-' num2str(iCount)];
sfullpath = fullfile(Vsavepath,[sfname '.mat'])
if exist(Vsavepath) == 0
    mkdir(Vsavepath);
end
disp('Saving the Signal File')
save(sfullpath,'dffV','-v7.3');
disp('File Saved')
end

