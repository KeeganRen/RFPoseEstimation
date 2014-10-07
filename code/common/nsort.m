%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [val, sub] = nsort(v, param)
[val, ind] = sort(v(:), param);
sub = nind2sub(size(v), ind);
