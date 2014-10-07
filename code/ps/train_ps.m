%
%  train_ps
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%

addpath(genpath(fullfile(pwd, '../')));

try
    load('../../data/FOOTBALL_ps_data.mat');
catch
    imagedir = '../../dataset/FOOTBALL12m/';
    scoredir = '../../data/score_maps/score_maps_FOOTBALL12m_P10_C50/';
    modelname = 'model_regr_FOOTBALLm_14p_P10C50';
    nTrain = 180*2;

    train_ims = 1:nTrain;

    % load dataset annotation
    files = dir([imagedir '*.jpg']);
    load([imagedir 'labels.mat']);

    load(sprintf('../../data/%s.mat', modelname));

    meanshift_params.num_clusters = 20;
    meanshift_params.neighbor_radius = 20;
    meanshift_params.kernel_gamma = 0.00001;
    meanshift_params.stop_threshold = 1;
    meanshift_params.stop_iterations = 100;
    meanshift_params.merge_threshold = 5;
    
    ps_params.nClusters = 6*ones(1,14);
    ps_params.lambda = 0.01;
    ps_params.up = [1 6 7 12 14 2 5 8 11 3 4 9 10 13];
    ps_params.pa = [2 3 9 10 4 5 8 9 13 13 10 11 0 13];
    ps_model = ps_fit(ptsAll(:,:,1:nTrain), ps_params);

    points = cell(1,14);
    weights = cell(1,14);
    
    msPts = zeros(14, 2, nTrain);
    oraclePts = zeros(14, 2, nTrain);
    gtPts = ptsAll(:,:,train_ims);
    
    psPts = cell(1, nTrain);
    psConf = cell(1, nTrain);
    psScores = cell(1, nTrain);
    pcpScores = cell(1, nTrain);
    
    for i=1:nTrain
        tic
        imname = files(train_ims(i)).name;
        fprintf('Loading score maps...\n');
        scmname = sprintf('%s%s.mat', scoredir, imname(1:end-4));
        load(scmname);
        toc
        
        tic
        fprintf('Evaluating decision forest...\n');
        input = reshape(score_maps,[size(score_maps,1) size(score_maps,2)...
            size(score_maps,3)*size(score_maps,4)]);
        output = forest_eval(input, model);
        toc
        
        tic
        fprintf('Finding modes using meanshift...\n');
        for p=1:14
            output_p = output(:,:,p+1);
            N = prod(double(size(output_p)));
            [val, sub, ind] = ntop(output_p, round(N*0.05));
            [Cs, Ds] = meanshift(sub, output_p(ind), meanshift_params);
            points{p} = [Cs(:,2) Cs(:,1)];
            weights{p} = log(Ds);
        end
        toc
        
        % mean shift max
        for p=1:14, msPts(p,:,i) = points{p}(1,:); end
        
        % pictorial structures matching
        [psPts{i} psConf{i} psScores{i}] = ps_nmatch(points, weights, ps_model);
        
        pcpScores{i} = evaluate_configuration_score(psPts{i}, gtPts(:,:,i));
        
        % oracle matching
        oraclePts(:,:,i) = oracle_match(points, gtPts(:,:,i));
    
        % visualize
        imname = files(train_ims(i)).name;
        im = imread([imagedir imname]);
        
        %subplot(1,2,1);
        %plot_configuration(im, gtPts(:,:,i));     
        %subplot(1,2,2);
        %sel = pcpScores{i} >= max(pcpScores{i});
        %plot_configuration(im, psPts{i}(:,:,sel));
        %title(['PCP: ' num2str(max(pcpScores{i}))]);
        %waitforbuttonpress;
    end
    
    save('../../data/FOOTBALL_ps_data.mat', 'ps_model', 'psPts', 'psConf', 'psScores', 'pcpScores');
    
end

try
    load('../../data/FOOTBALL_ps_calib.mat');
catch
    Xs = []; QIDs = []; Ts = [];
    
    disp('Creating feature vector...');
    for i=1:length(psScores)
        threshold = max(pcpScores{i});
        
        x = [psScores{i}.app psScores{i}.def psScores{i}.com_unary psScores{i}.com_pair];
        t = pcpScores{i} >= threshold;
        
        inds_pos = find(t, 1, 'first');
        inds_neg = find(t < threshold);
        inds = [inds_pos; inds_neg];
        x = x(inds, :);
        t = t(inds, :);
        
        qid = repmat(i, [size(x,1), 1]);
        
        Xs = [Xs; x];
        QIDs = [QIDs; qid];
        Ts = [Ts; t];
    end
    
    disp('Training...');
    C = length(unique(QIDs));    
    svmr_model = SVMRank();
    svmr_model = svmr_model.train(Xs, QIDs, Ts, C);
    
    save('../../data/FOOTBALL_ps_calib.mat', 'svmr_model', 'ps_model');
    
    nParts = ps_model.nParts;
    
    ps_model.coef.app       =  svmr_model.w(1,         1:  nParts);
    ps_model.coef.def       =  svmr_model.w(1,1*nParts+1:2*nParts);
    ps_model.coef.com_unary =  svmr_model.w(1,2*nParts+1:3*nParts);
    ps_model.coef.com_pair  =  svmr_model.w(1,3*nParts+1:4*nParts);
    
    save('../../data/FOOTBALL_ps_calib.mat', 'svmr_model', 'ps_model');
end


