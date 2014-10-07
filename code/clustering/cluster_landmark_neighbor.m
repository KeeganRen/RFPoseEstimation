addpath(genpath(fullfile(pwd, '../')));

rng('default');

imagedir = '../../dataset/FOOTBALL12m/';
nTrain = 180*2;
% imagedir = '../../dataset/FOOTBALL5907m/';
% nTrain = 3900*2;

% load dataset annotation
files = dir([imagedir '*.jpg']);
load([imagedir 'labels.mat']);

%ptsAll26 = round(PARSE_14to26(ptsAll));

trainPtsAll = permute(ptsAll(:,:,1:nTrain), [3 1 2]);

disp('caching images...');
cached_ims = cell(1,nTrain);
for i=1:nTrain
    cached_ims{i} = im2double(imread([imagedir files(i).name]));
end

close all

nClusters = 50;
nJoints = 14;
scale = [64 64];
c = 1e-3;
radius = 100;
lambda = 1/radius;

figure('Position',[0 0 1024 1024]);
colorset = {'g','y','m','y','r','y','c','c','y','y','y','b','b','b','b'};

for p=7:nJoints
    disp(['clustering joint ' num2str(p)]);
    v = bsxfun(@minus, trainPtsAll, trainPtsAll(:,p,:));
    r2 = sum(v.^2,3);
    r = sqrt(r2);
    w = exp(-c*r2)./r;
    w(r < eps) = 0;
    w(r > radius) = 0;
    r(r > radius) = 0;
    wv = reshape(bsxfun(@times, w, v), [nTrain nJoints*2]);    
    x = [wv, lambda*r];
    inds = kmeans(x, nClusters, 'emptyaction', 'singleton', 'replicate', 5,'distance','cosine');
    
    ims = cell(1, nClusters);
    for n=1:nClusters
        ims{n} = zeros(scale(1),scale(2),3);
        cinds = find(inds==n);
        for i=1:length(cinds)
            pos = reshape(trainPtsAll(cinds(i),p,:),[1 2]);
            croped_im = crop_bb(cached_ims{cinds(i)}, pos, scale);
            ims{n} = ims{n} + croped_im;
            %tightplot(1,length(cinds)+1,i);
            %imshow(croped_im);
        end
        ims{n} = ims{n} / length(cinds);
        
        %tightplot(1,length(cinds)+1,length(cinds)+1);
        %imshow(ims{n});
        %waitforbuttonpress;
        
        nPlotW = ceil(sqrt(nClusters));
        tightplot(nPlotW,nPlotW,n);
        imshow(ims{n});
        % visualize points
        hold on
        x = bsxfun(@plus, v(cinds,:,:), reshape(scale/2,[1 1 2]));
%         for j=1:nJoints
%             plot(x(:,j,1),x(:,j,2),[colorset{j} '.']);
%         end
%         hold off
    end
    drawnow;
    export_fig(sprintf('../../result/joint_cluster/part_%02d_im_ph.png',p));
    return
end



