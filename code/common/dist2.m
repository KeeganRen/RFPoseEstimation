% calculate the euclidean distance between two sets of vectors efficiently
% usage: d = dist2(x1,x2,w)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function d = dist2(x1,x2,w)

switch nargin
    case 1
        xx1 = repmat(sum(x1.*x1,2),[1, size(x1,1)]);
        d = xx1 + xx1' - 2*(x1*x1');
    case 2
        xx1 = repmat(sum(x1.*x1,2),[1, size(x2,1)]);
        xx2 = repmat(sum(x2.*x2,2),[1, size(x1,1)]);
        d = xx1 + xx2' - 2*x1*x2';     
end

