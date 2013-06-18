function [ img ] = colorspaceconvert( img, colorspace )
% Input
%   img         rgb or gray image
%   colorspace  'grayscale', 'rgb', 'transform', 'opponent' or 'c'
%               default is 'opponent'
% Output
%   img     convertend double img

img = im2double(img);
height = size(img,1);
width = size(img,2);

if strcmp(colorspace,'grayscale')
    if size(img,3) == 3
        img = rgb2gray(img);
    end
    return
end

%% here colorspace is rgb, transform, opponent or c

if size(img,3) == 1
    img = repmat(img,[1 1 3]);
end

if strcmp(colorspace,'rgb')
    return
end

img = reshape(img,[height*width 3]);
if strcmp(colorspace,'transform')
    img = (img-repmat(mean(img),height*width,1))./repmat(std(img),height*width,1);
    img = reshape(img,[height width 3]);
    return
end

%% here colorspace is opponent or c

curimg = img;
img(:,1) = (curimg(:,1)-curimg(:,2))/sqrt(2);
img(:,2) = (curimg(:,1)+curimg(:,2)-2*curimg(:,3))/sqrt(6);
img(:,3) = sum(curimg,2)/sqrt(3);
if strcmp(colorspace,'c')
    img3 = img(:,3);
    img3(img3==0) = 1;
    img(:,1) = img(:,1)./img3;
    img(:,2) = img(:,2)./img3;
elseif ~strcmp(colorspace,'opponent')
    warning(['WARNING: UNKNOWN COLOR SPACE - ' colorspace])
end
img = reshape(img,[height width 3]);

end
