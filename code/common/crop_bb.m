%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function cim = crop_bb(im, pos, scale)

ul = floor(pos-scale/2)+[1 1];
lr = floor(pos+scale/2-1)+[1 1];

inds1 = crop_array(ul(2), lr(2), size(im,1));
inds2 = crop_array(ul(1), lr(1), size(im,2));

if(max(inds1)>size(im,1) || max(inds2)>size(im,2) || min(inds1)<1 || min(inds2)<1)
    disp('error');
end

cim = im(inds1, inds2,:);

end


function inds = crop_array(starti, endi, sz)

inds = [];
if starti<1
    inds = 2-starti:-1:2;
end

inds = [inds, max(1,starti):min(sz,endi)];

if endi>sz
    inds = [inds, sz-1:-1:2*sz-endi];
end

end
