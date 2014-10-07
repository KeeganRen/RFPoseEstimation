function show_occlusion()

rng('default');

imagedir = '../dataset/FOOTBALL5907m/';
modelname = '../data/model_football5907.mat';
nTrain = 3900*2;

% load dataset annotation
files = dir([imagedir '*.jpg']);
load([imagedir 'labels.mat']);

load(modelname);

%% generate occluded images
test_im = nTrain + 2;
imname = files(test_im).name; 
im = imread([imagedir imname]); 
next_pos = [1,1];
randPts = [...
   135    44;
   122   209;
    51   174;
   196   119;
    63    73;
   182    25;
    70   220;
    69    31;
   166   227;
     0   122;];

%% generate results

points = cell(1,14);
weights = cell(1,14);

vid = VideoWriter('../result/occ.avi', 'Uncompressed AVI');
vid.FrameRate = 10;

open(vid);

fig = figure(1);
set(fig, 'Position',[10 10 1000 380]);
set(fig, 'Color',[0 0 0]);
set(gca,'nextplot','replacechildren');
set(gcf,'Renderer','zbuffer');
axis off;


for i=1:200
    alpha = mod(i-1,20)/19;
    if alpha==0
        last_pos = next_pos;
        next_pos = randPts(floor((i-1)/20)+1,:);
        oc_size = randi([40 100],[1,2]);
        cim = im(1:oc_size(1),1:oc_size(2),:);
    end    
    interp_pos = round(alpha*next_pos + (1-alpha)*last_pos);    
    oc_im = paste_image(im, cim, interp_pos);      

    feats = feature_compute_same(oc_im, model.featureParams);
    feats = feature_compress(feats);
    output = forest_eval(feats, model);
    
    for p=1:14
        output_p = output(:,:,p+1);
        N = prod(double(size(output_p)));
        [val, sub] = ntop(output_p, round(N*0.05));
        [Cs, Ds] = meanshift(sub, val, model.meanshift_params);
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
    visualize_modes(oc_im, points, weights, 7);
    fs = 14;
    title('Probability Modes', 'FontSize', fs, 'Color', [1 1 1]);
    
    tightplot(1,3,2,0.01);
    visualize_pixel_labels(output(:,:,2:end));
    title('Pixel Classification', 'FontSize', fs, 'Color', [1 1 1]);
    
    tightplot(1,3,3,0.01);    
    lines = [1,2;2,3;3,4;4,5;5,6;3,9;9,10;4,10;7,8;8,9;10,11;11,12;13,14];
    visualize_configuration(oc_im, psPts, lines, 8);
    title('Predicted Configuration', 'FontSize', fs, 'Color', [1 1 1]);
        
    drawnow;
    
    frame = getframe(fig);
    writeVideo(vid, frame);
end

close(vid);

