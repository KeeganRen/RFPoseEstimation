% spectral_cluster(X, k, c)
% cluster data to k clusters using spectral clustering algorithm
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function idx = spectral_cluster(S, k)

% % mutual k-nn graph
% W = zeros(n, n);
% for i=1:n
%     [val inds] = ntop(S(:,i), 10);
%     W(inds(:,1),i) = val;
% end
% W = min(W, W');

% full matrix
W = S;

% % epsilon neighborhood
%W = S.*double(S > 0.01);

G = diag(sum(W));

L = G - W;
%L = eye(n,n) - inv(G)*W;
%L = eye(n,n) - sqrt(inv(G))*W*sqrt(inv(G));

[U,~] = eig(L);
[~,inds] = sort(diag(D),'ascend');
Z = U(:,inds(2:k+1));

% % normalize to one
% for i=1:size(Z,1)
%     Z(i,:) = Z(i,:) / norm(Z(i,:));
% end

idx = kmeans(Z, k, 'emptyaction', 'singleton');

end
