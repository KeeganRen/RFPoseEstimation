%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [r, T] = rotate_points_around(v, theta, center1, center2)

if(nargin==3)
    center2 = center1;
end

T = Transform.create('t',-center1);
T = T * Transform.create('r',theta);
T = T * Transform.create('t',center2);
r = Transform.coords(v, T);

end
