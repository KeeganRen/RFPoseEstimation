%
%  [D, ind] = distranf4(f, mu, invd)
%
%  Created by Vahid Kazemi
%  July 2011
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [D, ind] = distransf4(f, mu, invd)

D = f;
ind = zeros(size(f,1), size(f,2), size(f,3), size(f,4), 4);

for i=1:size(f,1)
    for j=1:size(f,2)
        for k=1:size(f,3)
            [D(i,j,k,:), ind(i,j,k,:,4)] = distransfer1(D(i,j,k,:), mu(4), invd(4));
        end
    end
end

for i=1:size(f,1)
    for j=1:size(f,2)
        for k=1:size(f,4)
            [D(i,j,:,k), ind(i,j,:,k,3)] = distransfer1(D(i,j,:,k), mu(3), invd(3));            
            ind(i,j,:,k,4) = ind(i,j,ind(i,j,:,k,3),k,4);
        end
    end
end

for i=1:size(f,1)
    for j=1:size(f,3)
        for k=1:size(f,4)
            [D(i,:,j,k), ind(i,:,j,k,2)] = distransfer1(D(i,:,j,k), mu(2), invd(2));
            ind(i,:,j,k,3) = ind(i,ind(i,:,j,k,2),j,k,3);
            ind(i,:,j,k,4) = ind(i,ind(i,:,j,k,2),j,k,4);
        end
    end
end

for i=1:size(f,2)
    for j=1:size(f,3)
        for k=1:size(f,4)
            [D(:,i,j,k), ind(:,i,j,k,1)] = distransfer1(D(:,i,j,k), mu(1), invd(1));
            ind(:,i,j,k,2) = ind(ind(:,i,j,k,1),i,j,k,2);
            ind(:,i,j,k,3) = ind(ind(:,i,j,k,1),i,j,k,3);
            ind(:,i,j,k,4) = ind(ind(:,i,j,k,1),i,j,k,4);
        end
    end
end

end
