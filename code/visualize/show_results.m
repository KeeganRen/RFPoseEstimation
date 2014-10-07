function show_results

% load dataset annotation
imagedir  = '../dataset/FOOTBALL12m/';
treefile = '../data/forest_football.mat';
modelfile = '../data/model_football.mat';

files = dir([imagedir '*.jpg']);
load([imagedir 'labels.mat']);
load(treefile);
load(modelfile);

nTrain = 180*2;

test_ims = nTrain+1:length(files);
nTest = length(test_ims);

%fmpPtsAll = baseline_convertFMPPoints(points);

points = cell(1,14);
weights = cell(1,14);

figure(1);
set(1, 'Position',[1 1 200 800]);

mkdir('../../result/sup/');

for i=1:nTest
    imname = files(test_ims(i)).name;        
    im = imread([imagedir imname]);

    fprintf('Evaluating decision forest...\n');
    feats = feature_compute_same(im, model.featureParams);
    feats = feature_compress(feats);
    output = forest_eval(feats, model);
    
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

    % visualize
    im = imread([imagedir imname]);        
    
    % pixel classification
    tightplot(4,1,1,0.005);
    visualize_pixel_labels(output(:,:,2:end));

    % modes
    tightplot(4,1,2,0.005);
    visualize_modes(im, points, weights, 2);
    
    % ps output
    tightplot(4,1,3,0.005);
    lines = [1,2;2,3;3,4;4,5;5,6;3,9;9,10;4,10;7,8;8,9;10,11;11,12;13,14];
    visualize_configuration(im, psPts, lines, 5);
    
    % fmp
    tightplot(4,1,4,0.005);
    %visualize_configuration(im, fmpPtsAll(:,:,i), lines, 5);
    
    drawnow
    export_fig(sprintf('../result/result_%d.pdf',i),'-transparent');
end


