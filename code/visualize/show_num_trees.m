function show_num_trees()

% load dataset annotation
imagedir  = '../dataset/FOOTBALL12m/';
modelfile = '../data/model_football.mat';

files = dir([imagedir '*.jpg']);
load([imagedir 'labels.mat']);
load(modelfile);

m{1}.trees = model.trees(1);
m{2}.trees = model.trees(1:2);
m{3}.trees = model.trees(1:3);
m{4}.trees = model.trees(1:4);
m{5}.trees = model.trees(1:5);

% testing
test_im = 362;

h = figure(1);
set(h, 'Position', [0, 0, 1024, 350]*0.6);

imname = files(test_im).name;

im = imread([imagedir imname]);
feats = feature_compute_same(im, model.featureParams);
feats = feature_compress(feats);


tightplot(1,6,1,0.01,0.8);
sz = size(forest_eval(feats, m{1}));
im = imresize(im, sz(1:2));
imshow(im);

for j=1:5    
    tightplot(1,6,1+j,0.01, 0.8);
    output = forest_eval(feats, m{j});
    visualize_pixel_labels(output(:,:,2:end));
    title(sprintf('T = %d', j));
    %text(35, 280, sprintf('T = %d', j));
end
drawnow;
export_fig('../result/tree_number.pdf','-transparent');
