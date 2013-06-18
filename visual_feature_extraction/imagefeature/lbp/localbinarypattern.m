function feaVec = localbinarypattern( img, colorspace, blocknum )
% GIST
% Input
%   img
%   colorspace
%   blocknum        blocknum^2 regions
% Output
%   feaVec

height = floor(size(img,1)/blocknum)*blocknum;
width = floor(size(img,2)/blocknum)*blocknum;
img = imresize(img, [height width]*blocknum);
img = colorspaceconvert(img,colorspace);
cnum = size(img,3);
feaVec = zeros(blocknum^2*256*cnum,1);
rind = 0;
for rxind = 0:blocknum-1
    for ryind = 0:blocknum-1
        for cind = 1:cnum
            feaVec((1:256)+256*rind,1) = lbp(img((1:height)+height*rxind,(1:width)+width*ryind,cind))';
            rind = rind+1;
        end
    end
end

end
