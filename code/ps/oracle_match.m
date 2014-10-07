%
%  best_pts = oracle_match(points, gt_pts)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function best_pts = oracle_match(points, gt_pts)

nLandmarks = length(points);
best_pts = zeros(nLandmarks,2);

for l=1:nLandmarks
    [~,sel] = min(sum(bsxfun(@minus, points{l}, gt_pts(l,:)).^2,2));
    best_pts(l,:) = points{l}(sel,:);
end
