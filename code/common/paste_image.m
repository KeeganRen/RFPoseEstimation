%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function im = paste_image(im, cim, pos)

t1 = pos(1)-floor(size(cim,1)/2-0.5):pos(1)+floor(size(cim,1)/2);
t2 = pos(2)-floor(size(cim,2)/2-0.5):pos(2)+floor(size(cim,2)/2);

s1 = 1:size(cim,1);
s2 = 1:size(cim,2);

ind1 = find(t1 > 0 & t1 <= size(im,1));
ind2 = find(t2 > 0 & t2 <= size(im,2));

t1 = t1(ind1);
s1 = s1(ind1);
t2 = t2(ind2);
s2 = s2(ind2);

im(t1, t2,:) = cim(s1, s2, :);

end
