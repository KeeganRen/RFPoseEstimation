%
%  [clusters, clusParams] = cluster_patches(imagedir, trainNames, 
%        trainPoints, ldaModel, featureParams, clusParams)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [clusters, clusParams] = cluster_patches(imagedir,...
    trainNames, trainPoints, ldaModel, featureParams, clusParams)

if nargin<6, 
    clusParams.nClustersPerLandmark = 50;
    clusParams.nPatchesPerLandmark = 5;
    clusParams.nLandmarks = size(trainPoints,1);
    clusParams.radius = 5;
    clusParams.method = 'spectral';
    clusParams.threshold = 0.02;
    clusParams.normalize = true;
end

nFiles = length(trainNames);
featureSize = feature_size(featureParams);
featureLength = prod(featureSize);
nLandmarks = clusParams.nLandmarks;
nPatchesPerLandmark = clusParams.nPatchesPerLandmark;
nClustersPerLandmark = clusParams.nClustersPerLandmark;

patches = zeros(prod(featureParams.patchSize)*3, nPatchesPerLandmark,...
    nFiles, nLandmarks);
features = zeros(featureLength, nPatchesPerLandmark, nFiles, nLandmarks);
wfeatures = zeros(featureLength, nPatchesPerLandmark, nFiles, nLandmarks);

for i=1:nFiles
    imname = [imagedir trainNames{i}];
    im = imread(imname);
    sz = size(im);
    pts = trainPoints(:,:,i);
    disp(['Loading image : ' trainNames{i}]);

    if isfield(clusParams, 'partSegment')
        fgmask = clusParams.partSegment(sz, pts);
    end
        
    for p=1:nLandmarks
        
        if isfield(clusParams, 'partSegment')            
            inds = find(fgmask(:,:,p) > 0);
            inds = inds(randperm(length(inds)));
            inds = inds(1:nPatchesPerLandmark);
            [pos(:,2), pos(:,1)] = ind2sub(sz, inds);
        else
            randvs = [0,0; randi([-clusParams.radius clusParams.radius],...
                [nPatchesPerLandmark*5 2])];
            randvs = randvs(find(sum(randvs.^2, 2)<=clusParams.radius^2,...
                nPatchesPerLandmark, 'first'), :);
            pos = round(bsxfun(@plus, pts(p,:), randvs));
        end
        
        for k=1:nPatchesPerLandmark            
            patch = crop_bb(im, pos(k,:), featureParams.patchSize);
            assert(all(size(patch)==[featureParams.patchSize 3]))
            patches(:,k,i,p) = double(patch(:))/255;
            
            feature = feature_compute(patch, featureParams);
            features(:,k,i,p) = feature(:);
            
            wfeature = lda_whiten(feature, ldaModel);
            %wfeature = lda_whiten_old(reshape(feature, featureSize), ldaModel);
            if isfield(clusParams, 'threshold')
                wfeature(wfeature < clusParams.threshold) = 0;
                wfeature = wfeature / norm(wfeature(:));
            end
            wfeatures(:,k,i,p) = wfeature(:);
            
%            subplot(1,4,1);
%            show_hog(reshape(feature, featureSize));
%            subplot(1,4,2);
%            show_hog(reshape(wfeature, featureSize));
%            subplot(1,4,3);
%            imshow(patch);
%            subplot(1,4,4);
%            show_hog(reshape(lda_learn_old(...
%                load('../data/bg2.mat'), feature), featureSize));
%            waitforbuttonpress;
        end
    end
end

patches = reshape(patches, [prod(featureParams.patchSize)*3 ...
    nPatchesPerLandmark*nFiles nLandmarks]);
features = reshape(features, [featureLength ...
    nPatchesPerLandmark*nFiles nLandmarks]);
wfeatures = reshape(wfeatures, [featureLength ...
    nPatchesPerLandmark*nFiles nLandmarks]);

% cluster all the patches togeather
disp('Clustering...');

for p=1:nLandmarks
    switch clusParams.method
        case 'kmeans'
            [inds, ~] = calc_kmeans(wfeatures(:,:,p), nClustersPerLandmark);
        case 'spectral'
            sim = intersection(wfeatures(:,:,p));
            inds = spectral_cluster(sim, nClustersPerLandmark,...
                clusParams.nEigenVectors);
        case 'discriminative'
            % choose clusters by cross validation
    end

    % train fileters
    for i=1:nClustersPerLandmark
        sel = find(inds == i);
        filter = lda_whiten(features(:, sel, p), ldaModel);
        %selFeatures = reshape(features(:, sel, p), [featureSize, numel(sel)]);
        %filter = lda_whiten_old(selFeatures, ldaModel);
        meanPatch = reshape(mean(patches(:, sel, p),2),...
            [featureParams.patchSize 3]);
        fid = (p-1)*nClustersPerLandmark + i;
        clusters.filters(:, :, :, fid) = filter;
        clusters.patches(:, :, :, fid) = meanPatch;
    end
end

disp('Done.');

