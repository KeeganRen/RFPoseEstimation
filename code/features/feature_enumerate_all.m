%
%  feats = feature_enumerate_all(feat, featureSize, step)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function feats = feature_enumerate_all(feat, featureSize, step)

if nargin<3
    step = 1;
end

assert(size(feat,3)==featureSize(3));

[x1, y1] = meshgrid(...
    1:step:size(feat, 2)-featureSize(2)+1,...
    1:step:size(feat, 1)-featureSize(1)+1);

x2 = x1 + featureSize(2) - 1;
y2 = y1 + featureSize(1) - 1;

nElements = numel(x1);
feats = zeros([featureSize nElements]);
for i = 1:nElements
    feats(:,:,:,i) = feat(y1(i):y2(i), x1(i):x2(i), :);
end
