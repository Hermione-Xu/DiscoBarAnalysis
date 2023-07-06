function [MyPixel] = GetPixelData(fid,whichpixel,nFrames,FrameSize)
%% read any one pixel across time from the binary file
% fid           = file handle
% whichpixel    = pixel coordinates : rows, columns
% nFrames       = how many timestamples to read
% FrameSize     = size of the original frame

pixelformat = 'uint16';
bytesperpix = 2; % uint16

% whichpixel = [100, 100];
pixeloffset = ((whichpixel(1)-1)*FrameSize(1)) + (whichpixel(2)-1); % in pixels
pixeloffset = bytesperpix * pixeloffset; % in bytes

frameoffset = bytesperpix*((FrameSize(1)*FrameSize(2))-1);

% set file pointer accordingly for one pixel
fseek(fid, pixeloffset, 'bof');

MyPixel = fread(fid,[1, nFrames],pixelformat,frameoffset);

end

