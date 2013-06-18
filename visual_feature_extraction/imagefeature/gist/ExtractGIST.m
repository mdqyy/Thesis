function [ Xgist ] = ExtractGIST( dirname, blocknum, curblock )
%現在のディレクトリにある画像ファイルから根こそぎGIST抽出を行います。

if nargin==1
    blocknum=1;
    curblock=1;
end

files=dir([dirname filesep '*.jpg']);
blocksize=ceil(size(files,1)/blocknum);

disp([int2str(size(files,1)) ' images ...'])


% Parameters:
imageSize = 128; 
orientationsPerScale = [8 8 4];
numberBlocks = 4;

% Precompute filter transfert functions (only need to do this one, unless
% image size is changes):
G = createGabor(orientationsPerScale, imageSize);

from=blocksize*(curblock-1)+1;
to=min(blocksize*curblock,size(files,1));

Xgist=zeros(960,to-from+1);

for I=1:to-from+1

    fprintf('\r%s',files(from+I-1).name)

    % image path and name
    Imgtmp = imread([dirname filesep files(from+I-1).name]);

    % image resize
    Imgtmp = imresize(Imgtmp,[imageSize imageSize]);

    % Computing gist requires 1) prefilter image, 2) filter image and collect
    % output energies
    % output = prefilt(double(Imgtmp), 4);
    % temp=output-repmat(min(min(min(output))),[size(output)]);
    % temp=temp./repmat(max(max(max(temp))),[size(output)]);
    % image(temp)
    % drawnow
    Xgist(:,I) = gistGabor(Imgtmp, numberBlocks, G);
    % Xgist(:,I) = gistGabor(output, numberBlocks, G);

end

fprintf('\n')

end