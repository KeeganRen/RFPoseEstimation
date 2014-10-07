%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function val = clamp(val, minval, maxval)
val = bsxfun(@min, bsxfun(@max, val, minval), maxval);
end
