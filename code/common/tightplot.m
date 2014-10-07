%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function tightplot(n,m,i,off,scale)
if nargin<4
    off = [0 0];
elseif length(off)==1
    off(2) = off(1);
end

if nargin<5
    scale = 1;
end

[c,r] = ind2sub([m n], i);

shift = (1-scale)/2;

m = m/scale;
n = n/scale;

subplot('Position', [shift+(c-1)/m, -shift+1-(r)/n, 1/m-off(1), 1/n-off(2)*2])
