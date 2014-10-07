%
%  [fgmask, bgmask] = segment_image(sz, pts, radius, margin)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [fgmask, bgmask] = segment_image(sz, pts, radius, margin)

fgmask = zeros(sz(1),sz(2));

[x, y] = meshgrid(1:radius*2+1, 1:radius*2+1);
sel = (y-radius-1).^2+(x-radius-1).^2<=radius.^2;
x = x(sel) - radius -1;
y = y(sel) - radius -1;

for p=1:size(pts,1)
    curX = clamp(x + pts(p,1), 1, sz(2));
    curY = clamp(y + pts(p,2), 1, sz(1));
    curInds = sub2ind(sz, curY, curX);
    fgmask(curInds) = 1;
end

if nargout>1
    bgmask = ~imdilate(fgmask, strel('disk',margin));
end

end
