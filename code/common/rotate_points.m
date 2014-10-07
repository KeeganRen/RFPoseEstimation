%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function r = rotate_points(v, theta)

T = Transform.create('r',theta);
r = Transform.coords(v, T);

end
