%
%  [D, ind] = distranf3(f, mu, invd)
%
%  Created by Vahid Kazemi
%  July 2011
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [D, ind] = distransf3(f, mu, invd)

D = f;
ind = zeros(size(f,1), size(f,2), size(f,3), 3);

for i=1:size(f,1)
    for j=1:size(f,2)
        [D(i,j,:), ind(i,j,:,3)] = distransfer1(D(i,j,:), mu(3), invd(3));
    end
end

for i=1:size(f,1)
    for j=1:size(f,3)
        [D(i,:,j), ind(i,:,j,2)] = distransfer1(D(i,:,j), mu(2), invd(2));
        ind(i,:,j,3) = ind(i,ind(i,:,j,2),j,3);
    end
end

for i=1:size(f,2)
    for j=1:size(f,3)
        [D(:,i,j), ind(:,i,j,1)] = distransfer1(D(:,i,j), mu(1), invd(1));
        ind(:,i,j,2) = ind(ind(:,i,j,1),i,j,2);
        ind(:,i,j,3) = ind(ind(:,i,j,1),i,j,3);
    end
end

end
