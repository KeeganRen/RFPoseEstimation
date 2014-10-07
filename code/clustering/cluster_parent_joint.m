function clusters = cluster_parent_joint(imagedir, nTrain)

files = dir([imagedir '*.jpg']);
load([imagedir 'labels.mat']);

% parameters
nClusters = 16;
nJoints = 14;
scale = [64 64];
angles = [-8 -4 -2 0 2 4 8]*pi/180;

nAngles = length(angles);
pa = [2 3 9 10 4 5 8 9 13 13 10 11 0 13];

disp('caching images...');
cached_ims = cell(1,nTrain);
for i=1:nTrain
    im = im2double(imread([imagedir files(i).name]));
    cached_ims{i} = im;
end

disp('rotating annotation...');
rpoints = zeros(nTrain*nAngles, 2, 14);
thetas = zeros(nTrain*nAngles, 1);
iminds = zeros(nTrain*nAngles, 1);
for i=1:nTrain
    for a=1:nAngles
        idx = (i-1)*nAngles+a;
        rpts = rotate_points(ptsAll(:,:,i), angles(a));
        rpoints(idx, :, :) = permute(rpts,[2 1]);
        thetas(idx) = angles(a);
        iminds(idx) = i;
    end
end
points = permute(ptsAll(:,:,1:nTrain), [3 2 1]);

clusters = cell(nJoints,nClusters);
for p=1:nJoints
    disp(['clustering joint ' num2str(p)]);    
    if pa(p) ==0
        c = 1;
        while pa(c)~=p, c = c+1; end
        x = rpoints(:,:,c) - rpoints(:,:,p);
    else
        x = rpoints(:,:,p) - rpoints(:,:,pa(p));
    end    
    inds = kmeans(x, nClusters, 'replicates', 5, 'emptyaction', 'singleton', 'distance','cosine');
    
    for n=1:nClusters
        meanim = zeros(scale(1),scale(2),3);
        cinds = find(inds==n);
        for i=1:length(cinds)
            im = cached_ims{iminds(cinds(i))};
            pos = points(iminds(cinds(i)), :, p);
            theta = thetas(cinds(i));
            croped_im = crop_obb(im, pos, scale, theta);
            meanim = meanim + croped_im;
        end
        meanim = meanim / length(cinds);               
        
        clusters{p,n}.meanim = meanim;
        clusters{p,n}.im = iminds(cinds);
        clusters{p,n}.pos = points(iminds(cinds), :, p);
        clusters{p,n}.theta = thetas(cinds);
    end
end
