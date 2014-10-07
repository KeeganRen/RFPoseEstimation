%
%  meanshift
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [out_centers, out_density, out_inds] = meanshift(X, weights, params)

N = size(X,1);
nDim = size(X,2);
nstd = norm(std(X));

if nargin<2 || isempty(weights), weights = ones(N,1); end

if nargin<3, params = struct(); end
if ~isfield(params,'init'), params.init = 'subsample'; end
if ~isfield(params,'num_clusters'), params.num_clusters = 10; end
if ~isfield(params,'neighbor_radius'), params.neighbor_radius = 0.1*nstd; end
if ~isfield(params,'kernel_gamma'), params.kernel_gamma = 0.01; end
if ~isfield(params,'stop_threshold'), params.stop_threshold = 0.002*nstd; end
if ~isfield(params,'stop_iterations'), params.stop_iterations = 100; end
if ~isfield(params,'merge_threshold'), params.merge_threshold = 0.02*nstd; end

% initialize clusters
if ischar(params.init)
    switch params.init
        case 'subsample'
            if params.num_clusters < size(X, 1)
                ind = randperm(size(X, 1));
                ind = ind(1:params.num_clusters);
                Cs = X(ind,:);
            else
                Cs = X;
            end
        case 'uniform'
            Cs = repmat(min(X, [], 1), [params.num_clusters 1]);
            Cs = Cs + bsxfun(@times, rand(params.num_clusters, 1), max(X, [], 1)-min(X, [], 1));
    end
else
    Cs = params.init;
end
       
K = length(Cs);
density = zeros(K,1);

% find modes
for i=1:K
    for j=1:params.stop_iterations
        r2 = sum(bsxfun(@minus, X, Cs(i,:)).^2,2);
        inds_i = find(r2 < params.neighbor_radius.^2);
        Xi = X(inds_i,:);
        K = weights(inds_i).*exp(params.kernel_gamma*r2(inds_i));
        sumk = sum(K);
        C = sum(bsxfun(@times, K, Xi),1)/sumk;
        if norm(Cs(i,:)-C)<params.stop_threshold
            density(i) = sumk/N;
            Cs(i,:) = C;
            break;
        end
        density(i) = sumk/N;
        Cs(i,:) = C;
    end
end

% remove empty clusters
sel = density > 0;
density = density(sel, :);
Cs = Cs(sel, :);

% join connected clusters
G = sparse(dist2(Cs) < params.merge_threshold.^2);
[S, C] = graphconncomp(G);
      
out_centers = zeros(S,nDim);
out_density = zeros(S,1);
for i=1:S
    out_centers(i,:) = mean(Cs(C==i,:),1);
    out_density(i) = mean(density(C==i));
end

% sort clusters based on density
[out_density, oinds] = sort(out_density,'descend');
out_centers = out_centers(oinds,:);

if nargout>2
    num_clusters = size(out_centers, 1);
    [~, out_inds] = min(sum(bsxfun(@minus, X, reshape(out_centers', [1 nDim num_clusters])).^2,2),[],3);
end

end

function d=dist2(x)
xx = repmat(sum(x.*x,2),[1, size(x,1)]);
d = xx + xx' - 2*(x*x');
end
