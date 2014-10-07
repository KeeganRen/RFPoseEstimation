function show_output()

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

scrsz = get(0,'ScreenSize');
figure('Position',[50 100 900 400]);

for i=1:nTest
    imname = files(test_ims(i)).name;
    
    im = imread([imagedir imname]);
        
    fprintf('Evaluating decision forest...\n');
    feats = feature_compute_same(im, model.featureParams);
    feats = feature_compress(feats);
    output = forest_eval(feats, model);
    
    tightplot(2,nTest,i,0.01);
    imshow(im);
    
    tightplot(2,nTest,nTest+i,0.01);
    visualize_pixel_labels(output(:,:,2:end));
    drawnow;
end

export_fig('../result/output.pdf','-transparent');
