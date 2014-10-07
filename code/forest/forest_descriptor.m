% descriptors: nTrees x featureLength x 3 dimensional matrix
%   consists of [offX, offY, F] (set during initialization)
function descriptors = forest_descriptor(params)

offsets = randi([-params.radius params.radius], params.featureLength*5, 2);
inds = find(sum(offsets.^2,2)<=params.radius.^2, params.featureLength, 'first');
types = randi([0 params.nTypes-1], params.featureLength, 1);

descriptors = [offsets(inds, :) types];
