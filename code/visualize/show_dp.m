function show_dp()

% load dataset annotation
imagedir  = '../dataset/FOOTBALL12m/';
treefile = '../data/forest_football.mat';
modelfile = '../data/model_football.mat';

files = dir([imagedir '*.jpg']);
load([imagedir 'labels.mat']);
load(treefile);
load(modelfile);
nTrain = 180*2;

points = cell(1,14);
weights = cell(1,14);

test_im = 180 + 486;

figure(1);
set(1, 'Position',[1 1 450 220]);

imname = files(test_im).name;
im = imread([imagedir imname]);
feats = feature_compute_same(im, model.featureParams);
feats = feature_compress(feats);

output = forest_eval(feats, model);

for p=1:14
    output_p = output(:,:,p+1);
    N = prod(double(size(output_p)));
    [val, sub, ind] = ntop(output_p, round(N*0.05));
    [Cs, Ds] = meanshift(sub, output_p(ind), model.meanshift_params);
    points{p} = [Cs(:,2) Cs(:,1)];
    weights{p} = log(Ds);
end

% mean shift max
msPts = zeros(14,2);
for p=1:14, msPts(p,:) = points{p}(1,:); end

% pictorial structures matching
psPts = ps_match(points, weights, model.ps_model);

% visualize
im = imread([imagedir imname]);

% modes
tightplot(1,3,1,0.005,0.8);
visualize_modes(im, points, weights, 2);
title('Probability Modes');

lines = [1,2;2,3;3,4;4,5;5,6;3,9;9,10;4,10;7,8;8,9;10,11;11,12;13,14];

tightplot(1,3,2,0.005,0.8);
visualize_configuration(im, msPts, lines, 5);
title('Max');

% ps output
tightplot(1,3,3,0.005,0.8);
visualize_configuration(im, psPts, lines, 5);
title('DP');


export_fig('../result/dp.pdf','-transparent');

