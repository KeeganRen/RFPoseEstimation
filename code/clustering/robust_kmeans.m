function [bestInds, bestCenters] = robust_kmeans(X, nClusters, params)

if nargin<3, params = []; end
if ~isfield(params, 'nIterations'); params.nIterations = 100; end
if ~isfield(params, 'threshold'); params.threshold = 0.01; end
if ~isfield(params, 'nReplicates'); params.nReplicates = 5; end

n = size(X, 2);

bestC = inf;
bestInds = [];
bestCenters = [];

for r=1:params.nReplicates
    % kmeans
    [inds, centers] = calc_kmeans(X, nClusters, params);
    
    % calculate cluster compactness
    C = 0;
    for i=1:nClusters
        cv = std(X(inds==i));
        cn = sum(inds==i);
        C = C + (cn/n) * cv;
    end
    
    % choose the best
    if C < bestC
        bestInds = inds;
        bestCenters = centers;
    end
end
