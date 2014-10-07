%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function sigma = covariance(x, y)

cx = bsxfun(@plus, x, -par_mean(x));
cy = bsxfun(@plus, y, -par_mean(y));
sigma = par_mean(cx.*cy);

end
