%%%%%%%%%%%%
tic;
%%%%%%%%%%%%

[~, pathinfo] = fileattrib('../');
addpath(genpath([pathinfo.Name '/imagefeature/']));
addpath(genpath([pathinfo.Name '/yael_v300/matlab/']));

if matlabpool('size') > 0
    matlabpool close force local
end
matlabpool

% -------------------------------------------------------------------------
% parameter setting

% database retrieval
skip_db_retrieving = false;
labels_by_dirnumbers = true; % false means labels are numbered by dictionary-order

% feature extraction
skip_descriptor_saving = true;

desc_param = struct;
desc_param.patchSize = [32];
desc_param.gridspacing = 6;

feature_type = desc_feaset.selectdesc;
desc_obj = desc_feaset(feature_type,desc_param);

skip_desc_extracting = false;

% -------------------------------------------------------------------------
% set path

workbench = '/home/mil/letrungkien/test_descs/';
img_path = '/home/mil/letrungkien/test_images/';

desc_dir = ...
    [workbench '/' feature_type '/'];
tdb_path = ...
    fullfile(workbench,[feature_type '_database.mat']);
db_path = ...
    fullfile(workbench,['database.mat']);

if exist('workbench','var') && ~exist(workbench,'file'); mkdir(workbench); end
if exist('desc_dir','var')  && ~exist(desc_dir,'file');  mkdir(desc_dir); end

% -------------------------------------------------------------------------
% retrieve the image database directory
if skip_db_retrieving
    load(db_path);
    if isempty(database),
        error('Data directory error!');
    end
else
    fprintf('retrieving the database directory...\n');

    database = struct;
    database.imnum = 0; % total image number of the database
    database.nclass = 0;

    subfolders = dir(img_path);
    for ii = 1:length(subfolders)

        subname = subfolders(ii).name;
        if ~strcmp(subname, '..')

            frames = [dir(fullfile(img_path, subname, '*.jpg')); ...
                      dir(fullfile(img_path, subname, '*.JPG')); ...
                      dir(fullfile(img_path, subname, '*.jpeg')); ...
                      dir(fullfile(img_path, subname, '*.JPEG'));];

            c_num = length(frames);           
            if c_num == 0
                continue;
            end

            database.nclass = database.nclass + 1;
            database.imnum = database.imnum + c_num;
        end
    end

    database.cname = cell(1,database.nclass); % name of each class
    database.label = zeros(1,database.imnum); % label of each class
    database.path = cell(1,database.imnum); % contain the pathes for each image of each class

    imcount = 0;
    clcount = 0;
    for ii = 1:length(subfolders)
        subname = subfolders(ii).name;

        if ~strcmp(subname, '..')

            frames = [dir(fullfile(img_path, subname, '*.jpg')); ...
                      dir(fullfile(img_path, subname, '*.JPG')); ...
                      dir(fullfile(img_path, subname, '*.jpeg')); ...
                      dir(fullfile(img_path, subname, '*.JPEG'));];

            c_num = length(frames);
            if c_num == 0
                continue;
            end
            if ~skip_descriptor_saving && ~exist(fullfile(desc_dir,subname),'file')
                mkdir(desc_dir,subname);
            end
            clcount = clcount+1;
            database.cname{clcount} = subname;
            if labels_by_dirnumbers
                database.label(imcount+1:imcount+c_num) = str2double(subname);
            else
                database.label(imcount+1:imcount+c_num) = clcount;
            end

            for jj = 1:c_num
                imcount = imcount+1;
                database.path{imcount} = fullfile(img_path, subname, frames(jj).name);
            end
        end
    end
    save(db_path,'database');
end


% -------------------------------------------------------------------------
% prepare the descriptor database directory
if exist(tdb_path,'file')
    load(tdb_path);
else
    tgtdatabase = struct;
    tgtdatabase.path = cell(1,length(database.label)); % contain the pathes for each image of each class
    for ind = 1:length(tgtdatabase.path)
        tgtdatabase.path{ind} = strrep(database.path{ind},img_path,desc_dir);

        periodind = strfind(tgtdatabase.path{ind},'.');
        tgtdatabase.path{ind} = [tgtdatabase.path{ind}(1:periodind(end)) 'mat'];

        filesepind = strfind(tgtdatabase.path{ind},filesep);
        if ~exist(tgtdatabase.path{ind}(1:filesepind(end)),'file')
            mkdir(tgtdatabase.path{ind}(1:filesepind(end)));
        end
    end
    save(tdb_path,'tgtdatabase');
end

% -------------------------------------------------------------------------
% extract local descriptors
if ~skip_desc_extracting
    fprintf('starting descriptor extracting\n');

    parfor ind = 1:database.imnum

        if ~mod(ind, 5),
            fprintf('.');
        end
        if ~mod(ind, 100) && ind > 0
            fprintf(' %d images processed\n', ind);
        end

	I = imread(database.path{ind});
        feaSet = desc_obj.extract(I,tgtdatabase.path{ind});
    end
end

toc