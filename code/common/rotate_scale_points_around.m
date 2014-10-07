%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [r, T] = rotate_scale_points_around(v, theta, center1, center2, scale)

if(nargin==3)
    center2 = center1;
end

T = transform_create('t',-center1);
T = T * transform_create('r',theta);
T = T * transform_create('t',center2);
T = T * transform_create('s',scale);
r = transform_coords(v, T);

end
