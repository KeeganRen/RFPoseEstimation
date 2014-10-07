%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function draw_bbox(rc, color, size)
if(nargin<2)
    color = 'b';
end
if nargin<3
    size = 1;
end
rectangle('Position', [rc(2)-rc(4)/2, rc(1)-rc(3)/2, rc(4), rc(3)], ...
    'EdgeColor', color,'LineWidth',size);
end
