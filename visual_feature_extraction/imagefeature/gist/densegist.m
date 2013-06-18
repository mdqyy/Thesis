function [ feaSet ] = densegist( img, gridspacing, ssize, mwidth, orientationsPerScale, imageSize )
% dense color descriptor
% Input
%   img                     image matrix. any types are welcomed.
%   gridspacing             default is 6.
%   ssize                   # of row cells and column cells. default is 4.
%   mwidth                  width of each cell. default is [4 6 9 12 16].
%   orientationsPerScale    gabor filter parametor. default is [8 8 4].
%   imageSize               images are resized to imageSize-by-imageSize.
%                           default is 320, # of desc. will be 12126.
% Output
%   feaSet

if size(img,1) ~= imageSize || size(img,2) ~= imageSize
    img = imresize(img,[imageSize imageSize]);
end

%% filter generating
global GistFilter
if isempty(GistFilter) || imageSize ~= GistFilter.imsize
    GistFilter.G = createGabor(orientationsPerScale, imageSize);
    GistFilter.imsize = imageSize;
end

%% image colorspace fixing
if ndims(img)==2
    img = img(:,:,[1 1 1]);
end
Nfilters = size(GistFilter.G,3);

%% gist filtering
img = single(fft2(img));
img = abs(ifft2(img(:,:,[ones(1,Nfilters) 2*ones(1,Nfilters) 3*ones(1,Nfilters)]).* ...
    GistFilter.G(:,:,[1:Nfilters 1:Nfilters 1:Nfilters])));
colornum = size(img,3);

feaSet = struct('feaArr',[],'x',[],'y',[],'width',imageSize,'height',imageSize);
for mwind = 1:length(mwidth)

    % img smoothing and converting
    img = imresize(imresize(img,1/mwidth(mwind)),[imageSize imageSize]); % to calculate the mean of each cell instead of averaging

    % patch seed and image reshaping
    patchsize = (ssize-1)*mwidth(mwind)+1;
    [patchparent_x,patchparent_y] = meshgrid(0:mwidth(mwind):patchsize-1,0:mwidth(mwind):patchsize-1);
    patches = reshape(img,[imageSize^2 colornum]);

    % small patche per grid
    [global_x,global_y] = meshgrid(1:gridspacing:imageSize-patchsize, 1:gridspacing:imageSize-patchsize);
    patchnum = numel(global_x);
    global_x = reshape(global_x(:),[1 1 patchnum]);
    global_y = reshape(global_y(:),[1 1 patchnum]);
    % x-y coodinate for each patch
    patchparent_x = patchparent_x(:,:,ones(1,patchnum))+ ...
                global_x(ones(1,ssize),ones(1,ssize),:);
    patchparent_x = reshape(patchparent_x(:),[ssize^2 patchnum]);
    patchparent_y = patchparent_y(:,:,ones(1,patchnum))+ ...
                global_y(ones(1,ssize),ones(1,ssize),:);
    patchparent_y = reshape(patchparent_y(:),[ssize^2 patchnum]);
    % x-y coodinate of matrix to absolute index
    patchindeces=(patchparent_x-1)*imageSize+patchparent_y;
    patches = reshape(reshape(patches(patchindeces,:),[ssize^2*patchnum colornum])',[ssize^2*colornum patchnum]);
    % feaSet concatenating
    feaSet.feaArr = cat(2,feaSet.feaArr,double(patches));
    feaSet.x = cat(1,feaSet.x,global_x(:)+floor(patchsize/2));
    feaSet.y = cat(1,feaSet.y,global_y(:)+floor(patchsize/2));

end

end

