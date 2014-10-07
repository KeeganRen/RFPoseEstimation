%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function crim = crop_obb(im, pos, scale, theta)

d = round(sqrt(scale(1)*scale(1)+scale(2)*scale(2))) + 1;

cim = crop_bb(im, pos, [d d]);

rim = imrotate(cim, theta*180/pi, 'bilinear');

sz = size(rim);

crim = crop_bb(rim, round(sz(1,1:2)/2), scale);

end
