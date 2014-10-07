%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function K = intersection(A, B)

if nargin<2
    B = A;
end

K = zeros(size(A,2), size(B,2));
for i = 1:size(A,2)
    K(i,:) = sum(bsxfun(@min, A(:,i), B), 1);
end
