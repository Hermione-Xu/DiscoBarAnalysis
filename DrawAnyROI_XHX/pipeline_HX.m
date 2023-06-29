ops.hemoCorrect = true;

% TODO: stich multiple movies?
[im_file,im_path] = uigetfile('*.tif','Choose movie to draw ROI over');
im_filename = [im_path filesep im_file];

imageinfo=imfinfo(im_filename,'tiff');
numframes=length(imageinfo);
H=imageinfo(1).Height;
W=imageinfo(1).Width;

% Load blue frames and violet frames separately?
im_stack = zeros(H,W,numframes);
disp('Reading all images from this file...');
% TODO: could put b_stack and v_stack in here. save data storage space.
for frame = 1:numframes
    im_stack(:,:,frame) = imread(im_filename,'tiff',frame,'Info',imageinfo);
end
% TODO: how do I know which channel the first image belongs to? Idea: since
% each file has 3097 frames, odd number movies have blue as the first
% frame, and vice versa. BUT is there a more straightforward stamp to use?
im_bstack = im_stack(:,:,1:2:numframes);
im_vstack = im_stack(:,:,2:2:numframes);
disp('Done');

% 
% im_bstack = single(squeeze(im_bstack)); % store data in 32 bits instead of 64. save space.
% blueRef = fft2(median(im_bstack,3)); %blue reference for motion correction
% test mean out
blueRef_mean = fft2(mean(im_bstack,3));

% Motion correction for the blue channel
for iFrames = 1:size(im_bstack,3)
    [~, temp] = dftregistration(blueRef_mean, fft2(im_bstack(:, :, iFrames)), 10);
    im_bstack(:, :, iFrames) = abs(ifft2(temp));
%     [~, temp] = dftregistration(blueRef, fft2(im_bstack(:, :, iFrames)), 10);
%     im_bstack(:, :, iFrames) = abs(ifft2(temp));
end

% Export the two motion corrected files for easy comparison
% saveTiffStack_HX(test,im_filename); % It might be my illusion, but mean 
% seems better.
% imshow(test(:,:,1),[]) % auto scale

im_vstack = single(squeeze(im_vstack));
violetRef_mean = fft2(mean(im_vstack,3)); %violet reference for motion correction
% Motion correction for the violet channel
for iFrames = 1:min(size(im_bstack,3),size(im_vstack,3))
    [~, temp] = dftregistration(violetRef_mean, fft2(im_vstack(:, :, iFrames)), 10);
    im_vstack(:, :, iFrames) = abs(ifft2(temp));
end

baselineDur = 1:20; % some frames in which the mouse was not performing. 
% Need behavior timestamp because each session is different.
% Hemodynamic correction for individual pixels
if ops.hemoCorrect
    data = Widefield_HemoCorrect(im_bstack,im_vstack,baselineDur,5); %hemodynamic correction
else
    data = im_bstack;
end

% im_avg_binned = binImage(im_avg,ops.binning);
im_avg = mean(im_bstack,3);

svdROI_HX(ops,im_avg,im_bstack);