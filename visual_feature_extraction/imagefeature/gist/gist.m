function feaVec = gist( img, colorspace, orientations, scales, blocknum )
% GIST
% Input
%   img
%   colorspace
%   orientations
%   scales
%   blocknum        blocknum^2 regions
% Output
%   feaVec

imgsize = floor(max(size(img))/blocknum)*blocknum;
img = colorspaceconvert(img,colorspace);
img = imresize(img, [imgsize imgsize]);
G = createGabor(ones(1,scales)*orientations,imgsize);

feaVec = gistGabor(img,blocknum,G);

end

