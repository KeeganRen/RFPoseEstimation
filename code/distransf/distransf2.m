%
%  [D, ind] = distranf2(f, mu, invd)
%
%  Created by Vahid Kazemi
%  July 2011
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [D, ind] = distransf2(f, mu, invd)

D = f;
ind = zeros(size(f,1), size(f,2), 2);

for i=1:size(f,1)
    [D(i,:), ind(i,:,2)] = distransfer1(D(i,:), mu(2), invd(2));
end

for i=1:size(f,2)
    [D(:,i), ind(:,i,1)] = distransfer1(D(:,i), mu(1), invd(1));
    ind(:,i,2) = ind(ind(:,i,1),i,2);
end

end
