function [clusters, clusParams] = cluster_patches(imagedir,...
    trainNames, trainPoints, ldaModel, featureParams, clusParams)

nTrain = length(trainNames);

% parameters
if nargin<6
	clusParams.nClusters = 50;
	clusParams.nParts = 10;
	clusParams.nLandmarks = 14;
	clusParams.nRand = 30;
	clusParams.scale = [64 64];
	clusParams.c = 1e-3;
	clusParams.radius = 80;
	clusParams.lambda = 1/radius;
end

for p=1:nParts
    disp(['clustering joint ' num2str(p)]);
    
    v = parts(p).vs;
    r2 = sum(v.^2,3);
    r = sqrt(r2);
    w = exp(-c*r2)./r;
    w(r < eps) = 0;
    w(r > radius) = 0;
    r(r > radius) = 0;
    wv = reshape(bsxfun(@times, w, v), [nTrain*nRand nLandmarks*2]);    
    x = [wv, lambda*r];
    inds = kmeans(x, nClusters, 'emptyaction', 'singleton', 'replicate', 5);
    
    ims = cell(1, nClusters);
    for n=1:nClusters
        ims{n} = zeros(scale(1),scale(2),3);
        cinds = find(inds==n);
        for i=1:length(cinds)
            pos = parts(p).pos(cinds(i),:);
            croped_im = crop_bb(cached_ims{parts(p).id(cinds(i))}, pos, scale);
            ims{n} = ims{n} + croped_im;
        end
        ims{n} = ims{n} / length(cinds);

        nPlotW = ceil(sqrt(nClusters));
        tightplot(nPlotW,nPlotW,n);
        imshow(ims{n});
	drawnow;
    end
end



