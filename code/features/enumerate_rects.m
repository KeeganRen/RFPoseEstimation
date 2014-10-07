%
%  rois = enumerate_rects(rect, patchSize, step)
%  enumerate all the squares in a region with fixed size
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function rois = enumerate_rects(rect, patchSize, step)

if nargin<3
    step = 1;
end

x0 = rect(1);
y0 = rect(2);
width = rect(3)-rect(1)+1;
height = rect(4)-rect(2)+1;

nCols = round(width/step);
nRows = round(height/step);

[ys, xs] = ind2sub([nRows nCols], 1:nRows*nCols);
xs = bsxfun(@plus, bsxfun(@times, xs(:)-1, step), x0);
ys = bsxfun(@plus, bsxfun(@times, ys(:)-1, step), y0);

rois = [xs ys repmat(patchSize, [size(xs,1) 1])];
