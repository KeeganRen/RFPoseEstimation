function show_overview

% load dataset annotation
imagedir  = '../dataset/FOOTBALL12m/';
treefile = '../data/forest_football.mat';
modelfile = '../data/model_football.mat';

files = dir([imagedir '*.jpg']);
load([imagedir 'labels.mat']);
load(treefile);
load(modelfile);

nTrain = 180*2;

figure(1);
set(1, 'Position',[100 100 450 250]);

test_im = 405+180;

imname = files(test_im).name;

im = imread([imagedir imname]);

fprintf('Evaluating decision forest...\n');
feats = feature_compute_same(im, model.featureParams);
feats = feature_compress(feats);
output = forest_eval(feats, model);

points = cell(1,14);
weights = cell(1,14);
for p=1:14
    output_p = output(:,:,p+1);
    N = prod(double(size(output_p)));
    [val, sub] = ntop(output_p, round(N*0.05));
    [Cs, Ds] = meanshift(sub, val, model.meanshift_params);
    points{p} = [Cs(:,2) Cs(:,1)];
    weights{p} = log(Ds);
end

% pictorial structures matching
psPts = ps_match(points, weights, model.ps_model);
    

tightplot(1,4,1,0.01,0.8);
imshow(im);
title('Input');

tightplot(1,4,2,0.01,0.8);
visualize_pixel_labels(output(:,:,2:end));
title({'Pixel'; 'Classification'});

tightplot(1,4,3,0.01,0.8);
visualize_modes(im, points, weights);
title({'Probability'; 'Modes'});

tightplot(1,4,4,0.01,0.8);
lines = [1,2;2,3;3,4;4,5;5,6;3,9;9,10;4,10;7,8;8,9;10,11;11,12;13,14];
visualize_configuration_ex(im, psPts, lines);
title({'Predicted'; 'Configuration'});

export_fig('../result/overview.pdf','-transparent');
