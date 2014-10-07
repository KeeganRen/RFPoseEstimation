function football_test(dbname, visualize, saveOutput)

if nargin<1, dbname = 'football5907'; end
if nargin<2, visualize = true; end
if nargin<3, saveOutput = false; end

% dataset information
if strcmp(dbname, 'football')
    imagedir = '../dataset/FOOTBALL12m/';
    files = dir([imagedir '*.jpg']);
    load([imagedir 'labels.mat']);
    test_ims = 180*2+1:length(files);
    nTest = length(test_ims);
    testPoints = ptsAll(:,:,test_ims);
    testNames = cell(1, nTest);
    for i=1:nTest
        testNames{i} = files(test_ims(i)).name;
    end
elseif strcmp(dbname, 'football5907')
    imagedir = '../dataset/FOOTBALL5907m/';
    files = dir([imagedir '*.jpg']);
    load([imagedir 'labels.mat']);
    test_ims = 3900*2+1:length(files);
    nTest = length(test_ims);
    testPoints = ptsAll(:,:,test_ims);
    testNames = cell(1, nTest);
    for i=1:nTest
        testNames{i} = files(test_ims(i)).name;
    end
elseif strcmp(dbname, 'campus')
    imagedir = '../dataset/';
    load([imagedir 'CampusLM/test.mat']);
    nTest = length(testNames);
elseif strcmp(dbname, 'campus_masked')
    imagedir = '../dataset/';
    load([imagedir 'CampusLMmasked/test.mat']);
    nTest = length(testNames);
end


nLandmarks = size(testPoints,1);

msPts = zeros(nLandmarks, 2, nTest);
psPts = zeros(nLandmarks, 2, nTest);
oraclePts = zeros(nLandmarks, 2, nTest);
gtPts = testPoints;

lines = [1,2;2,3;3,4;4,5;5,6;3,9;9,10;4,10;7,8;8,9;10,11;11,12;13,14];

load(['../data/model_' dbname '.mat']);

if saveOutput
    mkdir(['../result/' dbname]);
end

for i=1:nTest
    imname = testNames{i};
    fprintf('Loading image %s...\n', imname);
    im = imread([imagedir imname]);
       
    % calculate filter responses    
    feats = feature_compute_same(im, model.featureParams);
    feats = feature_compress(feats); 
    
    % evalute the random forest
    output = forest_eval(feats, model);
    
    % find modes    
    points = cell(1,nLandmarks);
    weights = cell(1,nLandmarks);
    for p=1:nLandmarks
        output_p = output(:,:,p+1);
        N = prod(double(size(output_p)));
        [val, sub] = ntop(output_p, round(N*0.1));
        [Cs, Ds] = meanshift(sub, val, model.meanshift_params);  
        points{p} = [Cs(:,2) Cs(:,1)];
        weights{p} = log(Ds);      
    end
    
    % mean shift max
    for p=1:nLandmarks, msPts(p,:,i) = points{p}(1,:); end
    
    % dynamic programming
    psPts(:,:,i) = ps_match(points, weights, model.ps_model);
    
    % oracle matching
    oraclePts(:,:,i) = oracle_match(points, gtPts(:,:,i));

    if visualize
        h = figure(1);
        set(h, 'Position', [1 1 1000 400])
        subplot(1,3,1);
        visualize_pixel_labels(output(:,:,2:end));
        subplot(1,3,2);
        visualize_modes(im, points, weights, 2);
        subplot(1,3,3);
        visualize_configuration(im, psPts(:,:,i), lines, 5);
        drawnow;
        
        if saveOutput
            export_fig(['../result/' dbname '/' strrep(imname, '/', '_')]);
        end
    end
end

save(['../data/results_' dbname '.mat'], 'msPts', 'psPts', 'oraclePts', 'gtPts');

[detRate PCP R] = PARSE_eval_pcp(msPts, gtPts);
disp(['Mean shift: ' num2str(detRate*PCP)]);

[detRate PCP R] = PARSE_eval_pcp(psPts, gtPts);
disp(['DP matching: ' num2str(detRate*PCP)]);

[detRate PCP R] = PARSE_eval_pcp(oraclePts, gtPts);
disp(['Oracle matching: ' num2str(detRate*PCP)]);
