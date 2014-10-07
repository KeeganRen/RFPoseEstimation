%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function Y = sum_every_k(X, k)

assert(ndims(X)==2);

M = size(X,1);
N = size(X,2);
n = M/k;

assert(round(n)==n);

X = reshape(X,[k n N]);

Y = sum(X,1);

Y = reshape(Y, [n N]);

end
