% returns n highest scoring values of a list
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [val, sub, ind] = ntop(v0, n)

v = v0(:);

n = min(n, size(v,1));

minVal = min(v);
maxVal = max(v);
dVal = maxVal - minVal;

curInds = [];
k = 1;
seq = [0.0001 0.001 0.01 0.1 1];

while sum(curInds) < n
    curThresh = maxVal - dVal*seq(k);
    curInds = (v >= curThresh);
    k = k + 1;
end

ind0 = find(curInds);

[val1, ind1] = sort(v(ind0), 'descend');

ind = ind0(ind1(1:n));
sub = nind2sub(size(v0), ind);

val = val1(1:n);
