%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [val, sub] = nmin(v)

[val, ind] = min(v(:));
sub = nind2sub(size(v), ind);
