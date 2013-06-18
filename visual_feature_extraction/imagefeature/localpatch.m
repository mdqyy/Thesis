function [ feaSet ] = localpatch( img, colorspace, gridspacing, ssize, mwidth )
% dense color descriptor
% Input
%   img
%   colorspace      'grayscale', 'rgb', 'transform', 'opponent' or 'c'
%                   usually 'rgb'
%   gridspacing
%   ssize           ssize x ssize cells
%   mwidth          each cell is mwidth x mwidth pixels
% Output
%   feaSet

%% img smoothing and converting
height = size(img,1);
width = size(img,2);
img = imresize(imresize(img,1/mwidth),[height width]);
img = colorspaceconvert(img, colorspace);
colornum = size(img,3);

%% patch seed and image reshaping
patchsize = (ssize-1)*mwidth+1;
[patchparent_x,patchparent_y] = meshgrid(0:mwidth:patchsize-1,0:mwidth:patchsize-1);
patches = reshape(img,[height*width colornum]);

%% small patche per grid
[global_x,global_y] = meshgrid(1:gridspacing:width-patchsize, 1:gridspacing:height-patchsize);
patchnum = length(global_x(:));
% x-y coodinate for each patch
patchparent_x = repmat(patchparent_x,[1 1 patchnum])+ ...
                repmat(reshape(global_x(:),[1 1 patchnum]),[ssize ssize 1]);
patchparent_x = reshape(patchparent_x(:),[ssize^2 patchnum]);
patchparent_y = repmat(patchparent_y,[1 1 patchnum])+ ...
                repmat(reshape(global_y(:),[1 1 patchnum]),[ssize ssize 1]);
patchparent_y = reshape(patchparent_y(:),[ssize^2 patchnum]);
% x-y coodinate of matrix to absolute index
patchindeces=(patchparent_x-1)*height+patchparent_y;
patches = reshape(reshape(patches(patchindeces,:),[ssize^2*patchnum colornum])',[ssize^2*colornum patchnum]);
% subplot(2,1,2)
% image(img)
% for tind = 1:size(patches,2)
%     subplot(2,1,1)
%     image(reshape(reshape(patches(:,tind),[colornum ssize^2])',[ssize ssize colornum]));
%     drawnow
%     pause(0.01)
% end
feaSet = struct('feaArr',double(patches),'x',global_x(:)+floor(patchsize/2),'y',global_y(:)+floor(patchsize/2),'width',width,'height',height);

end

