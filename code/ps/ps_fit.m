%
%  model = ps_fit(points, params, visualize)
%
%  points: nParts x nDims x nSamples
%  up: vertices ordered from bottom to top
%  pa: parents
%  nClusters: Number of clusters for each part
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function model = ps_fit(points, params, visualize)

if nargin<3, visualize = false; end

nParts = size(points,1);
nDims = size(points, 2);

model = [];
model.nParts = nParts;
model.coef.app = 10*ones(1,nParts);
model.coef.def = ones(1,nParts);
model.coef.com_unary = ones(1,nParts);
model.coef.com_pair = ones(1,nParts);

% cluster points relative to a connected part
idx = cell(1, nParts);
C = cell(1, nParts);
for v=1:nParts
    if params.pa(v) ==0
        % find the first child
        c = 1;
        while params.pa(c)~=v, c = c+1; end
        X = shiftdim(points(c,:,:) - points(v,:,:))';
    else
        X = shiftdim(points(v,:,:) - points(params.pa(v),:,:))';
    end
    
    [idx{v} C{v}] = kmeans(X, params.nClusters(v), 'replicates', 5);
    
    if visualize
        nsp = ceil(sqrt(nParts));
        if nDims==2
            subplot(nsp,nsp,v);
            scatter(X(:,1), X(:,2), [], idx{v}, 'filled');
            hold on
            for cl=1:params.nClusters(v)
                plot(C{v}(cl,1), C{v}(cl,2), 'gx', 'MarkerSize', 10);
            end
            hold off
        else
            subplot(nsp,nsp,v);
            scatter3(X(:,1), X(:,2), X(:,3), [], idx{v}, 'filled');
            hold on
            for cl=1:params.nClusters(v)
                plot3(C{v}(cl,1), C{v}(cl,2), C{v}(cl,3), 'gx', 'MarkerSize', 10);
            end
            hold off
        end
    end
end

% for each part type, learn a prior and a conditional likelihood given the
% parent part type
model.bi = cell(1,nParts);
model.bij = cell(1,nParts);
model.psi = cell(1,nParts);
for v=1:nParts
    model.bi{v} = zeros(1, params.nClusters(v));
    for i=1:params.nClusters(v)
        inds = (idx{v} == i);
        model.bi{v}(i) = log(mean(inds) + params.lambda);
    end

    if params.pa(v)~=0
        model.bij{v} = zeros(params.nClusters(v), params.nClusters(params.pa(v)));
        model.psi{v}.mean = zeros(nDims, params.nClusters(v), params.nClusters(params.pa(v)));
        model.psi{v}.ivar = zeros(nDims, params.nClusters(v), params.nClusters(params.pa(v)));
        for i=1:params.nClusters(v)
            inds_i = (idx{v} == i);
            for j=1:params.nClusters(params.pa(v))
                inds_j = (idx{params.pa(v)} == j);
                inds_ij = inds_i & inds_j;
                model.bij{v}(i,j) = log(mean(inds_ij) + params.lambda);
                if sum(inds_ij)>1
                    dp = shiftdim(points(params.pa(v),:,inds_ij) - points(v,:,inds_ij));
                elseif sum(inds_i)>1
                    dp = shiftdim(points(params.pa(v),:,inds_i) - points(v,:,inds_i));
                else
                    dp = shiftdim(points(params.pa(v),:,:) - points(v,:,:));
                end                
                model.psi{v}.mean(:,i,j) = mean(dp,2);
                model.psi{v}.ivar(:,i,j) = 1./(var(dp,[],2) + params.lambda);
            end
        end
    end
end

% find the vertex order
norder = 1:nParts;
params.down = [];
while ~isempty(norder)
    inds = ismember(params.pa(norder), [0 params.down]);
    params.down = [params.down, norder(inds)];
    norder = norder(~inds);
end
params.up = params.down(end:-1:1);

model.params = params;
