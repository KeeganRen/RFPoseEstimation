function show_tree_depth

% load dataset annotation
imagedir  = '../dataset/FOOTBALL12m/';
treefile = '../data/forest_football.mat';
modelfile = '../data/model_football.mat';

files = dir([imagedir '*.jpg']);
load([imagedir 'labels.mat']);
load(treefile);
load(modelfile);

depths = [2 5 10 15 20];

for i=1:length(depths)
    m{i} = [];
    m{i}.trees = [];
    for j=1:length(model.trees)
        d = depths(i);
        n = 2^(treeParams.depth-d);
        m{i}.trees(j).nodes = model.trees(j).nodes(1:2^(d-1)-1,:);
        hist = sum_every_k(model.trees(j).hists, n);
        norm = 1./sum(hist,2);
        norm(isnan(norm)) = 0;
        m{i}.trees(j).leaves = bsxfun(@times, hist, norm);
    end
end

% testing
test_im = 243+180;

figure(1);
set(1, 'Position',[1 1 450 160]);

imname = files(test_im).name;

im = imread([imagedir imname]);
feats = feature_compute_same(im, model.featureParams);
feats = feature_compress(feats);

tightplot(1,1+length(depths),1,0.01,0.9);
sz = size(forest_eval(feats, m{1}));
im = imresize(im, sz(1:2));
imshow(im);

for j=1:length(depths)
    tightplot(1,1+length(depths),j+1,0.01,0.9);
    output = forest_eval(feats, m{j});
    visualize_pixel_labels(output(:,:,2:end), 2, 2);
    title(sprintf('Depth %d', depths(j)));
    %text(35, 280, sprintf('Depth %d', depths(j)));
end

export_fig('../result/tree_depth.pdf','-transparent');
