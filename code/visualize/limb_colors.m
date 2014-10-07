%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function colors = limb_colors(nColors)

if nColors==13
    colors = [...
        0 1 0;
        0 1 0;
        1 1 0;
        1 0 1;
        1 0 1;
        1 0 1;
        1 0 1;
        1 1 0;
        1 1 0;
        1 1 0;
        1 0 1;
        1 0 0;
        1 0 0;
        1 0 0];
else
	colors = hsv(nColors);
end


