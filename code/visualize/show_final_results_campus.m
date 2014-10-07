function show_final_results_campus()

imagedir = '../dataset/CampusLMmasked/';
load('../data/model_campus_masked.mat');

points = cell(1,14);
weights = cell(1,14);

examples = [1 1 744;2 0 398;2 0 658;2 0 700;2 1 380;2 1 652;2 1 698;2 2 674;2 1 702;2 2 736;3 0 461;3 2 462];
id_actor = examples(:,1);
id_cam = examples(:,2);
id_frame = examples(:,3);
nTest = size(examples, 1);

figure(1);
set(1, 'Position',[1 1 200 400]);

mkdir('../result/compare/');

lines = [1,2;2,3;3,4;4,5;5,6;3,9;9,10;4,10;7,8;8,9;10,11;11,12;13,14];

for i=1:nTest
    imname = sprintf('actor%d/campus4-c%d-%05d.jpg',...
        id_actor(i), id_cam(i), id_frame(i));
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
    tightplot(2,1,1,0.005);
    visualize_modes(im, points, weights, 2);
    
    % ps output
    tightplot(2,1,2,0.005);
    visualize_configuration_ex(im, psPts, lines, 5);
    
    export_fig(sprintf('../result/compare/compare_campus_%d.pdf',i),'-transparent');
end
