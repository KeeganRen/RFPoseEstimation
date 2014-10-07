%
%  [trees, params] = forest_train(imagedir, trainNames, trainPoints, 
%       filters, featureParams, params)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [trees, params] = forest_train(imagedir, trainNames, trainPoints, featureParams, params)

nTrain = length(trainNames);
nLandmarks = size(trainPoints, 1);

% initialize tree parameters
if nargin<5, params = []; end
if ~isfield(params, 'nPosPatch'),       params.nPosPatch = 100; end
if ~isfield(params, 'nNegPatch'),       params.nNegPatch = 1000; end
if ~isfield(params, 'jointRadius'),     params.jointRadius = 10; end
if ~isfield(params, 'jointMargin'),     params.jointMargin = 10; end
if ~isfield(params, 'nTrees'),          params.nTrees = 5; end
if ~isfield(params, 'depth'),           params.depth = 20; end
if ~isfield(params, 'radius'),          params.radius = 20; end
if ~isfield(params, 'featureLength'),   params.featureLength = 25000; end
if ~isfield(params, 'nNodeFeatures'),   params.nNodeFeatures = 5000; end
if ~isfield(params, 'nThresholdBins'),  params.nThresholdBins = 10; end
if ~isfield(params, 'minimumGain'),     params.minimumGain = 0.01; end
if ~isfield(params, 'minimumSamples'),  params.minimumSamples = 5; end
if ~isfield(params, 'thresholdMargin'), params.thresholdMargin = 0; end
if ~isfield(params, 'nTypes'),          params.nTypes = 32; end

params.nClasses = nLandmarks + 1;

trees = [];
    
nPatch = params.nPosPatch*nLandmarks + params.nNegPatch;
features = zeros(nTrain*nPatch, params.featureLength, 'int8');
labels = zeros(nTrain*nPatch, 1, 'int16');

for t = 1:params.nTrees    
    descriptors = forest_descriptor(params);
    
    tic
    for i=1:nTrain        
        imname = trainNames{i};
        fprintf('Loading image %s\n', imname);
        
        pts = round(trainPoints(:,:,i));
        im = imread([imagedir imname]);
        sz = size(im);
        
        newPoints = [];
        newLabels = [];        
        
        % foreground pixels
        for p=1:nLandmarks
            randvs = randi([-params.jointRadius params.jointRadius], [params.nPosPatch*5 2]);
            randvs = randvs(find(sum(randvs.^2, 2)<=params.jointRadius^2, params.nPosPatch, 'first'), :);
            curPoints = round(bsxfun(@plus, pts(p,:), randvs));
            newPoints = [newPoints; curPoints];
            newLabels = [newLabels; ones(params.nPosPatch,1,'int16')*p];
        end
        
        % background pixels
        if isfield(params, 'partSegment')
            bgmask = ~imdilate(any(params.partSegment(sz, pts),3), strel('disk',params.jointMargin));
        else
            [~, bgmask] = segment_image(sz, pts, params.jointRadius, params.jointMargin);
        end
        inds = find(bgmask > 0);
        inds = inds(randperm(length(inds)));
        curPoints = [];
        [curPoints(:,2) curPoints(:,1)] = ind2sub([sz(1), sz(2)], inds(1:params.nNegPatch));
        newPoints = [newPoints; curPoints];
        newLabels = [newLabels; zeros(params.nNegPatch,1,'int16')]; 
        
        % calculate filter responses      
        feats = feature_compute_same(im, featureParams);
        feats = feature_compress(feats);
        
        % make forest feature
        newFts = forest_feature(feats, newPoints, descriptors, params);
        
        labels(nPatch*(i-1)+1:nPatch*i,1) = newLabels;
        features(nPatch*(i-1)+1:nPatch*i,:) = newFts;
    end
    toc
    
    fprintf('Building the decision forest...\n');
    tic
    tree = forest_learn(features, labels, descriptors, params);
    trees = [trees, tree];
    toc
end
end
