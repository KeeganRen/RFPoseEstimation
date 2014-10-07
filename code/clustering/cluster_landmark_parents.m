addpath(genpath(fullfile(pwd, '../')));

rng('default');

imagedir = '../../dataset/FOOTBALL12m/';
nTrain = 180*2;
% imagedir = '../../dataset/FOOTBALL5907m/';
% nTrain = 3900*2;

% load dataset annotation
files = dir([imagedir '*.jpg']);
load([imagedir 'labels.mat']);

nClusters = 16;
nJoints = 14;
c = 0.001;
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

figure('Position',[0 0 1024 1024]);

for p=1:nJoints
    disp(['clustering joint ' num2str(p)]);
    
    if pa(p) ==0
        c = 1;
        while pa(c)~=p, c = c+1; end
        x = rpoints(:,:,c) - rpoints(:,:,p);
    else
        x = rpoints(:,:,p) - rpoints(:,:,pa(p));
    end    
    inds = kmeans(x, nClusters, 'replicates', 5, 'distance','cosine');
    
    %scatter(x(:,1),x(:,2),[],inds);
    %return
    
    ims = cell(1, nClusters);
    for n=1:nClusters
        ims{n} = zeros(scale(1),scale(2),3);
        cinds = find(inds==n);
        for i=1:length(cinds)
            idx = cinds(i);
            im = cached_ims{iminds(idx)};
            pos = points(iminds(idx), :, p);
            theta = thetas(idx);
            croped_im = crop_obb(im, pos, scale, theta);
            ims{n} = ims{n} + croped_im;
        end
        ims{n} = ims{n} / length(cinds);        
        nPlotW = ceil(sqrt(nClusters));
        tightplot(nPlotW,nPlotW,n);
        imshow(ims{n});
    end
    drawnow;
    export_fig(sprintf('../../result/joint_cluster/part_%02d_fmp.png',p));
    return
end
