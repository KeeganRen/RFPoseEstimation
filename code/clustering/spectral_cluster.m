%  spectral_cluster(X, nClusters, c)
%	
%  Cluster data to nClusters clusters using spectral clustering algorithm
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function idx = spectral_cluster(S, nClusters, nEigenVectors)

n = size(S,1);

W = S.*double(S > eps);
W = 0.5.*(W+W);

G = diag(1./sqrt(sum(W)));

L = eye(n,n) - G*W*G;

if nargin>2
    [U D] = eigs(L, nEigenVectors, 'sm');
else
    [U D] = eig(L);
end

[~,inds] = sort(diag(D),'ascend');
Z = U(:,inds(2:min(nClusters+1, length(inds)-1)));

% normalize to one
for i=1:size(Z,1)
    Z(i,:) = Z(i,:) / norm(Z(i,:));
end

[idx,~] = robust_kmeans(Z', nClusters);
idx = idx';

end
