%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [val inds] = max_every_k(X, k)

assert(size(X,2)==1);

N = size(X,1);
n = N/k;
X = reshape(X,[k n]);
[val inds] = max(X,[],1);
inds = (inds + k*(0:n-1))';
val = val';

end
