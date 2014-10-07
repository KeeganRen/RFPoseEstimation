%
%  scaledFeat = feature_resize(feat, scale, sz)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function scaledFeat = feature_resize(feat, scale, sz)

nDim = size(feat, 3);
scaledFeat = zeros(sz(1), sz(2), nDim);

for i=1:nDim
    sfeat = imresize(feat(:,:,i), scale);
    scaledFeat(:,:,i) = sfeat(1:sz(1), 1:sz(2), :);
end
