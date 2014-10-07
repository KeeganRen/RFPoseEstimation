function show_tree_depth_video

rng('default');

% load dataset annotation
imagedir  = '../dataset/FOOTBALL5907m/';
treefile = '../data/forest_football5907.mat';
modelfile = '../data/model_football5907.mat';

files = dir([imagedir '*.jpg']);
load([imagedir 'labels.mat']);
load(treefile);
load(modelfile);
nTrain = 3900*2;

%% build models at different depth levels
depths = 1:treeParams.depth;
for i=1:treeParams.depth
    m{i} = [];
    m{i}.trees = [];
    for j=1:length(model.trees)
        d = depths(i);
        n = 2^(treeParams.depth-d);
        m{i}.trees(j).nodes = model.trees(j).nodes(1:2^(d-1)-1,:);
        hist = sum_every_k(model.trees(j).hists, n);
        m{i}.trees(j).leaves = bsxfun(@times, hist, 1./sum(hist,2));
    end
end

%% testing
test_ims = nTrain+1:nTrain+20;
nTest = length(test_ims);

points = cell(1,14);
weights = cell(1,14);

vid = VideoWriter('../result/depth_change.avi', 'Uncompressed AVI');
vid.FrameRate = 10;

open(vid);

fig = figure(1);
set(fig, 'Position',[0 0 1000 380]);
set(fig, 'Color',[0 0 0]);
set(gca,'nextplot','replacechildren');
set(gcf,'Renderer','zbuffer');
   
for i=1:nTest
    imname = files(test_ims(i)).name;
    im = imread([imagedir imname]);
    feats = feature_compute_same(im, model.featureParams);
    feats = feature_compress(feats);
    
    for j=1:length(depths)        
        output = forest_eval(feats, m{j});        
        for p=1:14
            output_p = output(:,:,p+1);
            N = prod(double(size(output_p)));
            [val, sub, ind] = ntop(output_p, round(N*0.05));
            [Cs, Ds] = meanshift(sub, output_p(ind), model.meanshift_params);
            points{p} = [Cs(:,2) Cs(:,1)];
            weights{p} = log(Ds);
        end
        
        % pictorial structures matching
        psPts = ps_match(points, weights, model.ps_model);
        
        % pixel classification
        tightplot(1,3,1,0.01);
        numModes = 5;
        for p=1:14
            points{p} = points{p}(1:min(numModes, size(points{p},1)), :);
            weights{p} = weights{p}(1:min(numModes, size(points{p},1)));
        end
        visualize_modes(im, points, weights, 7);
        fs = 14;
        title('Probability Modes', 'FontSize', fs, 'Color', [1 1 1]);
        
        tightplot(1,3,2,0.01);
        visualize_pixel_labels(output(:,:,2:end));
        title(sprintf('Pixel Classification (Depth = %d)',depths(j)), 'FontSize', fs, 'Color', [1 1 1]);
        
        tightplot(1,3,3,0.01);
        lines = [1,2;2,3;3,4;4,5;5,6;3,9;9,10;4,10;7,8;8,9;10,11;11,12;13,14];
        visualize_configuration(im, psPts, lines, 8);
        title('Predicted Configuration', 'FontSize', fs, 'Color', [1 1 1]);
        
        drawnow;
        
    
        frame = getframe(fig);
        writeVideo(vid, frame);
    end
    
    for j=1:5
        writeVideo(vid, frame);
    end
end

close(vid);


