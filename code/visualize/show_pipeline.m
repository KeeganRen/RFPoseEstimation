function show_pipeline

% load dataset annotation
imagedir  = '../dataset/FOOTBALL12m/';
treefile = '../data/forest_football.mat';
modelfile = '../data/model_football.mat';

files = dir([imagedir '*.jpg']);
load([imagedir 'labels.mat']);
load(treefile);
load(modelfile);

nTrain = 180*2;
test_ims = nTrain+1:nTrain+11;
nTest = length(test_ims);

test_im = 239 + 180;

imname = files(test_im).name;
im = imread([imagedir imname]);

fprintf('Evaluating decision forest...\n');
feats = feature_compute_same(im, model.featureParams);
feats = feature_compress(feats);
output = forest_eval(feats, model);

subplot(1,2,1);
imshow(im);

subplot(1,2,2);
visualize_pixel_labels(output(:,:,2:end));

export_fig('../result/pipeline.png','-transparent');
