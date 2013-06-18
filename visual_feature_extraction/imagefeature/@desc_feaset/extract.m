function feaSet = extract( obj, img, tgtfile )
%DESC_FEASET/EXTRACT performs dense sampling
%   feaSet = desc_feaset.fit(img,tgtfile) extracts descriptors densely.
%   img doesn't need to be resized/repeated to be a square color image.
%
%   feaSet is a struct consisting of following variables.
%       feaArr
%       x
%       y
%       width
%       height

% Written by Y. Ushiku
% Jul. 17, 2012, ISI, UT

if nargin == 3 && exist(tgtfile,'file')
    try
        load(tgtfile);
        return;
    catch me
        disp(me.identifier)
        disp(me.message)
        for ind = 1:length(me.stack)
            disp(me.stack(ind))
        end
        eval(['!rm ' tgtfile]);
    end
end

desc_param = obj.desc_param;
gridspacing = obj.gridspacing;
type = obj.type;

%% GIST
if strcmpi(type,'GIST')
    feaSet = densegist(img, ...
        gridspacing, ...
        desc_param.ssize, ...
        desc_param.mwidth, ...
        desc_param.orientationsPerScale, ...
        desc_param.imageSize);
    if nargin ==3; save(tgtfile,'feaSet','-v7.3'); end
    return;
end

% resize
if ~isfield(desc_param,'maxImSize')
    desc_param.maxImSize = 500;
end
im_h = size(img,1); im_w = size(img,2); 
if max(im_h, im_w) > desc_param.maxImSize
    img = imresize(img, desc_param.maxImSize/max(im_h, im_w), 'bicubic');
end

%% SIFT
if strcmpi(type,'SIFT')
    % grayscale
    if size(img,3) == 3
        img = round(single(img(:,:,1))*0.2989+single(img(:,:,2))*0.5870+single(img(:,:,3))*0.1140)/255;
    else
        img = single(img)/255;
    end
    % extraction
    siftArr = [];
    points = [];
    for scaleind = 1:length(desc_param.patchSize)
        [f, d] = vl_dsift(img, 'size', desc_param.patchSize(scaleind)/4, 'step', gridspacing);
        [d, ~] = sp_normalize_sift(single(d), desc_param.nrml_threshold);
        siftArr = [siftArr d];
        points = [points f];
    end
    % struct
    feaSet = struct;
    feaSet.feaArr = siftArr;
    feaSet.x = points(1,:)';
    feaSet.y = points(2,:)';
    feaSet.width = size(img,2);
    feaSet.height = size(img,1);
    if nargin ==3; save(tgtfile,'feaSet','-v7.3'); end
    return;
end

%% CSIFT
%% RGBSIFT
%% OpponentSIFT
if strcmpi(type,'CSIFT') || strcmpi(type,'RGBSIFT') || strcmpi(type,'OpponentSIFT')
    scales = '';
    for psind = 1:length(desc_param.patchSize)
        scales = [scales sprintf('%1.1f',fix(desc_param.patchSize(psind)/4/gridspacing*10)/10) '+'];
    end
    scales(end) = [];
    tmp_id = fullfile(desc_param.tmp_dir,['vscd_' num2str(round(rand(1)*100000))]);
    imwrite(img,[tmp_id '.jpg'],'JPEG')
    
    cmdline = ['!' obj.cdesc_path '/colorDescriptor ' ...
        tmp_id '.jpg ' ...
        '--detector densesampling ' ...
        '--descriptor ' lower(type) ' ' ...
        '--ds_spacing ' num2str(gridspacing) ' ' ...
        '--ds_scales ' scales ' ' ...
        '--outputFormat binary ' ...
        '--output ' tmp_id '.bin > /dev/null'];
    % extraction
    eval(cmdline);
    [d, f] = readBinaryDescriptors([tmp_id '.bin']);
    eval(['!rm -f ' tmp_id '.bin ' tmp_id '.jpg'])
    % struct
    feaSet = struct;
    feaSet.feaArr = d';
    feaSet.x = f(:,1);
    feaSet.y = f(:,2);
    feaSet.width = size(img,2);
    feaSet.height = size(img,1);
    if nargin ==3; save(tgtfile,'feaSet','-v7.3'); end
    return;
end

%% LBP
if strcmpi(type,'LBP')
    if size(img,3) == 3
        img = round(single(img(:,:,1))*0.2989+single(img(:,:,2))*0.5870+single(img(:,:,3))*0.1140)/255;
    else
        img = single(img)/255;
    end
    % extraction
    d = []; f = [];
    for pind = 1:length(desc_param.patchSize)
        patchSize = desc_param.patchSize(pind);
        [grid_x,grid_y] = meshgrid(patchSize:gridspacing:size(img,2)-patchSize, ...
                                   patchSize:gridspacing:size(img,1)-patchSize);
        [feaArr, x, y] = lbpdescriptor(img, grid_x, grid_y, patchSize, desc_param.cellnum);
        d = [d feaArr]; f = [f;x y];
    end
    % struct
    feaSet = struct;
    feaSet.feaArr = d;
    feaSet.x = f(:,1);
    feaSet.y = f(:,2);
    feaSet.width = size(img,2);
    feaSet.height = size(img,1);
    if nargin ==3; save(tgtfile,'feaSet','-v7.3'); end
    return;
end

%% SSIM
if strcmpi(type,'SSIM')
    d = []; f = [];
    for pind = 1:length(desc_param.patchSize)
        patchSize = desc_param.patchSize(pind);
        windowradius = desc_param.windowradius(pind);
        feaSet = densessim( img, [], gridspacing, ...
            patchSize, ...
            windowradius, ...
            desc_param.rinterval, ...
            desc_param.tinterval, ...
            desc_param.autovarr, ...
            desc_param.salthresh );
        d = [d feaSet.feaArr];
        f = [f;feaSet.x feaSet.y];
    end
    % struct
    feaSet = struct;
    feaSet.feaArr = d;
    feaSet.x = f(:,1);
    feaSet.y = f(:,2);
    feaSet.width = size(img,2);
    feaSet.height = size(img,1);
    if nargin ==3; save(tgtfile,'feaSet','-v7.3'); end
    return;
end

%% ColorMeanVar
if strcmpi(type,'ColorMeanVar')
    d = []; f = [];
    for pind = 1:length(desc_param.patchSize)
        patchSize = desc_param.patchSize(pind);
        [grid_x,grid_y] = meshgrid(patchSize:gridspacing:size(img,2)-patchSize, ...
                                   patchSize:gridspacing:size(img,1)-patchSize);
        [feaArr, x, y] = colormeanvar(img, grid_x, grid_y, patchSize);
        d = [d feaArr]; f = [f;x y];
    end
    % struct
    feaSet = struct;
    feaSet.feaArr = d;
    feaSet.x = f(:,1);
    feaSet.y = f(:,2);
    feaSet.width = size(img,2);
    feaSet.height = size(img,1);
    if nargin ==3; save(tgtfile,'feaSet','-v7.3'); end
    return;
end

end

