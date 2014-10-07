%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function ind = nsub2ind(siz, sub)

switch(length(siz))
    case 1
        ind = sub2ind(siz, sub(:,1));
    case 2
        ind = sub2ind(siz, sub(:,1), sub(:,2));
    case 3
        ind = sub2ind(siz, sub(:,1), sub(:,2), sub(:,3));
    case 4
        ind = sub2ind(siz, sub(:,1), sub(:,2), sub(:,3), sub(:,4));
end
