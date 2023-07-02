% Tiff
tic
test1 = Tiff('test.tif','r');
% Suppress warning
w=warning('query','last');
id=w.identifier;
warning('off',id)

for m=1:3097
    test1.setDirectory(m);
    data = test1.read();
end
toc
test1.close();

%imread (faster)
tic
for i=1:3097
    test2 = imread('test.tif',i);
end
toc

