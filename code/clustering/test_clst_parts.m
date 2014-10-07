rng('default');

imagedir = '../data/FOOTBALL/';
load([imagedir 'labels.mat']);

params = [];
params.nClusters = 100;
params.nRand = 5;
params.nClosest = 2;
params.assignmentFactor = 0.1;
params.lambda = 1;
params.scale = [32 32];

clusters = cluster_neighbor_parts(trainNames, trainPoints, params);

m = ceil(sqrt(params.nClusters));
for i=1:params.nClusters
    clst = clusters{i};
    tightplot(m, m, i);
    imshow(clst.meanim);
end
