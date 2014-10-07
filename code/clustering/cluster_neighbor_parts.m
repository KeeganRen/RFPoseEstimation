function clusters = cluster_neighbor_parts(trainNames, trainPoints, params)

nTrain = length(trainNames);
nLandmarks = size(trainPoints,1);

id = zeros(params.nRand, nTrain);
pos = zeros(2, params.nRand, nTrain);
vs = zeros(2, nLandmarks, params.nRand, nTrain);

points = permute(trainPoints(:,:,1:nTrain), [2 1 3]);

disp('Caching images...');
cached_ims = cell(1,nTrain);
for i=1:nTrain
    cached_ims{i} = im2double(imread([trainNames{i}]));
    pts = trainPoints(:,:,i);
    sz = size(cached_ims{i});
    fgmask = any(PARSE_part_segment(sz, pts));
    
    inds = find(fgmask > 0);
    inds = inds(randperm(length(inds)));
    inds = inds(1:params.nRand);
    [randPts(2,:) randPts(1,:)] = ind2sub([sz(1), sz(2)], inds);
    v = bsxfun(@minus, points(:,:,i), reshape(randPts, [2 1 params.nRand]));
    
    id(:, i) = i;
    pos(:, :, i) = randPts;
    vs(:, :, :, i) = v;
end

id = id(:);
pos = reshape(pos, 2, params.nRand*nTrain);
xs = reshape(vs(1,:,:,:), nLandmarks, params.nRand*nTrain);
ys = reshape(vs(2,:,:,:), nLandmarks, params.nRand*nTrain);

clusters = cell(params.nClusters);

disp('Clustering...');
rs = squeeze(sqrt(sum(vs.^2,1)));
[nrs, ninds] = sort(rs, 1, 'ascend');
ninds = ninds(1:params.nClosest, :);
nrs = nrs(1:params.nClosest, :);
nas = exp(-params.assignmentFactor*nrs);
nxs = xs(ninds, :);
nys = ys(ninds, :);

w = 
dist = nxs'*nxs + nys'*nys;
sim = exp(-params.lambda*dist);

inds = robust_kmeans(xs, params.nClusters);

disp('Creating the mean image... ');
for n=1:params.nClusters
    cinds = find(inds==n);
    cid = id(cinds);
    cpos = pos(:, cinds)';
    
    meanim = zeros(params.scale(1), params.scale(2), 3);
    for i=1:length(cinds)
        croped_im = crop_bb(cached_ims{cid(i)}, cpos(i,:), params.scale);
        meanim = meanim + croped_im;
    end
    meanim = meanim / length(cinds);
    
    clusters{n}.meanim = meanim;
    clusters{n}.im = cid;
    clusters{n}.pos = cpos;
end
