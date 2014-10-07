function show_annotations

% dataset information
imagedir = '../dataset/FOOTBALL12m/';
files = dir([imagedir '*.jpg']);
load([imagedir 'labels.mat']);

% training split
train_ims = 1:180*2;
nTrain = length(train_ims);
trainPoints = ptsAll(:,:,train_ims);
trainNames = cell(1, nTrain);
for i=1:nTrain
    trainNames{i} = files(train_ims(i)).name;
end

lines = [1,2;2,3;3,4;4,5;5,6;3,9;9,10;4,10;7,8;8,9;10,11;11,12;13,14];

% show images
for i=1:nTrain
    im = imread([imagedir trainNames{i}]);
    pts = trainPoints(:,:,i);
    visualize_configuration(im, pts, lines);
    export_fig(sprintf('../result/compare2/ann_%d.pdf',i),'-transparent');
    waitforbuttonpress;
end
