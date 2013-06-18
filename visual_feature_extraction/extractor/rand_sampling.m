function [X] = rand_sampling(training, num_img, num_smp)
% sample local features for unsupervised codebook training
% local descriptors patches (LDPs) are built.

sift_database = retr_part_database(training, num_img);

num_per_img = round(num_smp/num_img);
num_smp = num_per_img*num_img;

X_sift = cell(1,num_smp);
sift_path = sift_database.path;

parfor ii = 1:num_img,
    fprintf('\t\t%d\n',ii);

    % load sift
    Tmp=load(sift_path{ii}); feaSet=Tmp.feaSet;
    % assuming that two grids of sift and lbp are same
    num_fea = size(feaSet.feaArr, 2);
    rndidx = randperm(num_fea);
    cur_num_per_img = min(num_per_img,num_fea);
    X_sift{ii} = feaSet.feaArr(:, rndidx(1:cur_num_per_img));

end;

X = cat(2,X_sift{:});

end

function [part_database1] = retr_part_database(database1, nimg)
    nimg_per_class = ceil(nimg/database1.nclass);
    nimg = database1.nclass * nimg_per_class;
    part_database1 = struct;
    part_database1.imnum = nimg;
    part_database1.cname = database1.cname;
    part_database1.nclass = database1.nclass;
    orig_label = database1.label;
    orig_path = database1.path;
    label1 = zeros(nimg,1);
    path1 = cell(1,nimg);
    parfor count = 1:nimg
        cind = ceil(count/nimg_per_class);
        cur_img_ind = find( orig_label==cind );
        cur_randperm = randperm(length(cur_img_ind));
        for imind = 1:nimg_per_class
            label1(count) = cind;
            path1{count} = orig_path{cur_img_ind(cur_randperm(imind))};
        end
    end
    part_database1.label=label1;
    part_database1.path=path1;
end