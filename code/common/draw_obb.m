%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function draw_obb(rc, color)
if(nargin<2)
    color = 'b';
end

x1 = rc(2)-rc(4)/2; x2 = rc(2)+rc(4)/2;
y1 = rc(1)-rc(3)/2; y2 = rc(1)+rc(3)/2;
pts = [y1, x1; y1, x2; y2, x2; y2, x1];
pts = rotate_points_around(pts, rc(5), rc(1:2));
patch(pts(:,2), pts(:,1), ones(4,1), 'FaceColor','none','EdgeColor', color);

