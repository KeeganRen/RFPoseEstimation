%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function sub = nind2sub(siz, ind)

sub = zeros(length(ind), length(siz));
switch(length(siz))
    case 2
        [sub(:,1) sub(:,2)] = ind2sub(siz, ind);
    case 3
        [sub(:,1) sub(:,2) sub(:,3)] = ind2sub(siz, ind);
    case 4
        [sub(:,1) sub(:,2) sub(:,3) sub(:,4)] = ind2sub(siz, ind);
end
