%
%  [D, ind] = distranf1(f, mu, invd)
%
%  Created by Vahid Kazemi
%  July 2011
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [D, ind] = distransf1(f, mu, invd)
disp('matlab implementation is slower, compile the mex file!');
n = length(f);
z = zeros(1, n+1);
z(1) = -inf;
z(2) = inf;
v = zeros(1, n);
v(1) = 1;
k = 1;

for q=2:n
    s = (((v(k)+mu)^2-(q+mu)^2)+(f(v(k))-f(q))/invd)/(2*(v(k)-q));
    while s <= z(k)
        k = k-1;
        s = (((v(k)+mu)^2-(q+mu)^2)+(f(v(k))-f(q))/invd)/(2*(v(k)-q));
    end
    k = k+1;
    v(k) = q;
    z(k) = s;
    z(k+1) = inf;
end

k = 1;
D = zeros(1, n);
ind = zeros(1, n);
for q=1:n
    while z(k+1)<q
        k = k+1;
    end
    ind(q) = v(k);
    D(q) = invd*(q - v(k) - mu)^2 + f(v(k));
end
end

