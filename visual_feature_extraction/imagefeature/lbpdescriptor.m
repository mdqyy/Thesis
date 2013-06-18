function [feaArr, x, y] = lbpdescriptor(img, grid_x, grid_y, patchsize, cellnum)
% LBPDESCRIPTOR Grid sampling of lbp discriptors.
%   [feaArr, x, y] = lbpdescriptor(img, grid_x, grid_y, patchsize) extracts
%   lbp descriptors in a grid sampling manner. feaArr is 1024-by-N  matrix.
%   Each column is a descriptor of lbp values from 2-by-2 cells. 
%
%   [feaArr, x, y] = lbpdescriptor(img, grid_x, grid_y, patchsize, cellnum)
%   also extracts lbp descriptors. You can determine the dimension of
%   descriptors as 256*cellnum dimensions.
%
% Example:
%   img = imread('test.jpg'); patchsize = 16; gridspacing = 6;
%   [grid_x,grid_y] = meshgrid(patchsize:gridspacing:size(img,2)-patchsize, ...
%                              patchsize:gridspacing:size(img,1)-patchsize);
%   [feaArr, x, y] = lbpdescriptor(img, grid_x, grid_y, patchsize);
%
% Written by Y. Ushiku
% Oct. 7, 2011, ISI, UT


% number of cells
if nargin<5
    cellnum = 4;
end

% check if patchsize is divisible by 4
patchsize = 4*round(patchsize/4);
cellmem = patchsize^2/cellnum;

% make img a gray image
if size(img,3) == 3
    img = sum(img,3)/3;
end

% convert img to lbp img
lbpimg = zeros(size(img));
lbpimg(2:end-1,2:end-1) = double(lbp(img,[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1],0,'i'))+1;

% extract all patches
x = grid_x(:); y = grid_y(:);
grid_x = y; % switch grid_x and grid_y
grid_y = x; % switch grid_x and grid_y
grid_ind = grid_x(:) + (grid_y(:)-1)*size(lbpimg,1);
patchnum = length(grid_ind);
patch_parent = bsxfun(@plus, repmat((1:patchsize)',1,patchsize), ...
                             (0:patchsize-1)*size(lbpimg,1))-1;
patches = lbpimg( bsxfun(@plus, grid_ind', repmat(patch_parent(:),1,patchnum)) );

% histgram for each cell of each patch
feaArr = reshape(histc(reshape(patches,cellmem,patchnum*cellnum),1:256), ...
                 256*cellnum,patchnum);

% L1 square normalization
feaArr = sqrt(bsxfun(@rdivide,feaArr,sum(abs(feaArr),1)));

end
