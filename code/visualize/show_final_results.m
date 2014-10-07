function show_final_results()

imagedir = '../dataset/FOOTBALL12m/';
nTrain = 180*2;

load ../data/result_FOOTBALL_FMP_RERANK_180.mat

% load dataset annotation
files = dir([imagedir '*.jpg']);
load([imagedir 'labels.mat']);

load('../data/model_football.mat');

points = cell(1,14);
weights = cell(1,14);

success = [181 182 183 221 222 242 247 257 327 395 419 421];
failure = [191 192 193 326 351 224 225 233];
test_ims = 180 + [success, failure];
nTest = length(test_ims);

figure(1);
set(1, 'Position',[1 1 200 600]);

mkdir('../result/compare/');

lines = [1,2;2,3;3,4;4,5;5,6;3,9;9,10;4,10;7,8;8,9;10,11;11,12;13,14];

for i=1:nTest
    imname = files(test_ims(i)).name;  
    im = imread([imagedir imname]);
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

    % modes
    tightplot(3,1,1,0.005);
    visualize_modes(im, points, weights, 2);
    
    % ps output
    tightplot(3,1,2,0.005);
    visualize_configuration_ex(im, psPts, lines, 5);
    
    % fmp
    tightplot(3,1,3,0.005);
    visualize_configuration_ex(im, fmp_points(:,:,test_ims(i)-360)*1.2, lines, 5);    
    
    export_fig(sprintf('../result/compare/compare_%d.pdf',i),'-transparent');
end
