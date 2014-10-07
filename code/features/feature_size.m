%
%  sz = feature_size(featureParams)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function sz = feature_size(featureParams)

im = zeros([featureParams.patchSize,3]);
feat = feature_compute(im,featureParams);
sz = size(feat);
if numel(sz)==2
    sz(3) = 1;
end
