function [feaArr, x, y] = colormeanvar(img, grid_x, grid_y, patchsize)
% COLORMEANVAR Grid sampling of color discriptors.
%   [feaArr, x, y] = colormeanvar(img, grid_x, grid_y, patchsize) extracts
%   color descriptors in a grid sampling manner. feaArr is 96-by-N matrix.
%   Each column is a descriptor of means and covariances of RGB values from
%   4-by-4 local cells. 
%   
% Example:
%   img = imread('test.jpg'); patchsize = 16; gridspacing = 6;
%   [grid_x,grid_y] = meshgrid(patchsize:gridspacing:size(img,2)-patchsize, ...
%                              patchsize:gridspacing:size(img,1)-patchsize);
%   [feaArr, x, y] = colormeanvar(img, grid_x, grid_y, patchsize);
%
% Written by Y. Ushiku
% Sep. 29, 2011, ISI, UT

% check if patchsize is divisible by 4
patchsize = 4*round(patchsize/4);

% fixed parameters
cellnum = 16;
cellmem = patchsize^2/cellnum;

% make img a color image
if size(img,3) == 1
    img = repmat(img,[1 1 3]);
end

% extract all patches
x = grid_x(:); y = grid_y(:);
grid_x = y; % switch grid_x and grid_y
grid_y = x; % switch grid_x and grid_y
grid_ind = grid_x(:) + (grid_y(:)-1)*size(img,1);
patchnum = length(grid_ind);
patch_parent = bsxfun(@plus, (0:2)*size(img,1)*size(img,2), repmat( ...
    reshape( bsxfun(@plus, repmat((1:patchsize)',1,patchsize), (0:patchsize-1)*size(img,1)), ...
             patchsize^2,1), 1, 3) )-1;
patches = img( bsxfun(@plus, grid_ind', repmat(patch_parent(:),1,patchnum)) );

% calculate means and covariances of each patch
pc_x = repmat( bsxfun(@plus, repmat((1:cellmem)',1,cellnum*patchnum), (cellmem:cellmem:patchsize^2*patchnum)-cellmem), 1, 3);
pc_y = bsxfun(@plus, 1:3, repmat(reshape(repmat(0:3:3*cellnum*patchnum-3,cellmem,1),patchsize^2*patchnum,1),1,3));
patchcells = sparse(pc_x, pc_y, double(patches(:)));
feaArr = reshape( ...
    [reshape( full(sum(patchcells,1)),            3, cellnum*patchnum); ...
     reshape( spdiags(patchcells'*patchcells,0),  3, cellnum*patchnum).^.5]/4, ...
    96, patchnum);
%     reshape( spdiags(patchcells'*patchcells,1)+ ...
%              spdiags(patchcells'*patchcells,-2), 3, cellnum*patchnum)]/4, ...

end