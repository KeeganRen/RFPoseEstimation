%
%  ps_test
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%

rng('default');

addpath(genpath(fullfile(pwd, '../')));

imageDir = '../../dataset/FOOTBALL12/';
files = dir([imageDir '*.jpg']);
load([imageDir 'labels.mat']);
nTrain = 180*2;

params.nClusters = repmat(5, [1 14]);
params.pa = [2 3 9 10 4 5 8 9 13 13 10 11 0 13];
params.lambda = 0.01;

im = imread([imageDir files(1).name]);
pts = ptsAll(:,:,1);

model = ps_fit(ptsAll(:,:,1:nTrain), params, false);

subplot(1,3,1);
imshow(im);
hold on
input = cell(1,14);
weights = cell(1,14);
colors = lines;
for i=1:14
    nRand = randi([4 5],1);
    dxy = [randn(nRand, 2)*50; 0 0];
    input{i} = bsxfun(@plus, pts(i,:), dxy);
    weights{i} = ones(nRand+1, 1);
    scatter(input{i}(:,1), input{i}(:,2), 30, colors(i,:), 'filled');
end
hold off

tic
[pts, conf] = ps_match(input, weights, model);
toc

subplot(1,3,2);
plot_configuration(im, pts);

tic
[n_pts,n_conf,n_scores] = ps_nmatch(input, weights, model);
toc

subplot(1,3,3);
plot_configuration(im, n_pts(:,:,1:5));


