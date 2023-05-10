function ops = get_coordinates_XHX(ops)
% Draw an oval, but still make an array with zeros at unwanted regions?


coorfile = [ops.fname(1:end-4) '_coor.mat']; % Generate file name for coordinates
reffile = [ops.fname(1:end-4) '_refimg.mat'];

if exist(fullfile(ops.fpath,coorfile), 'file')
    pos = load(fullfile(ops.fpath,coorfile));
    ops.pos = vertcat(pos.pos);
    refimg = load(fullfile(ops.fpath,reffile));
    ops.refimg = vertcat(refimg.maskedImage);
    disp('Loading PreExisting Coordinate Location for cropping!!')
else
    refimg = imread(ops.vfile_1,1);

    subplot(2,2,1);
    imshow(refimg);
    axis('on','image');
    title('Original Image');
    % Maximize the window to make it easier to draw
    g = gcf;
    g.WindowState = 'maximized';
    % Draw a circle
    uiwait(helpdlg('Please click and drag out a circle.'));
    h.Radius = 0;
    while h.Radius == 0
        h = drawcircle('Color', 'g', 'FaceAlpha', 0.4);
        pos = customWait(h);
        if h.Radius == 0
            uiwait(helpdlg('You double-clicked. You need to single click, then drag, then single click again.'));
        end
    end

    % Get coordinates of the circle.
    angles = linspace(0, 2*pi, 10000);
    x = cos(angles) * h.Radius + h.Center(1);
    y = sin(angles) * h.Radius + h.Center(2);

    subplot(2,2,2)
    imshow(refimg);
    axis('on','image');
    hold on
    plot(x,y,'r-','LineWidth',2);
    title('Original image with circle overlaid')

    % Get a mask of the circle
    mask = poly2mask(x,y,size(refimg,1),size(refimg,2));
    subplot(2,2,3);
    imshow(mask);
    axis('on','image');
    title('Circle Mask');
   
    % Mask the image with the circle
	maskedImage = refimg; % Initialize with the entire image.
	maskedImage(~mask) = 0;

    % Crop the image to the bounding box.
    props = regionprops(mask, 'BoundingBox');
    pos = vertcat(props.BoundingBox);
    maskedImage = imcrop(maskedImage, props.BoundingBox);
    % Display it in the lower right plot.
    subplot(2, 2, 4);
    imshow(maskedImage, []);
    % Change imshow to image() if you don't have the Image Processing Toolbox.
    title('Image masked with the circle');

    coorsave = input('Do you want to save the coordinate position (Yes = 1, No = 0): ');
    close(gcf) % Close multiple images
    if coorsave == 1
        ops.pos = pos;
        ops.refimg = maskedImage;
        save(fullfile(ops.fpath,coorfile), 'pos');
        save(fullfile(ops.fpath,[coorfile(1:end-8) 'refimg']),'maskedImage');
    end
end