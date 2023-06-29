dirpath = uigetdir;
obj = Tiff('HX5__000001.tif','r');
image_one = read(obj);
imagesc(image_one);
colormap(gray);

write(obj, squeeze(im2uint8(Imagelayer1)));

close(obj);