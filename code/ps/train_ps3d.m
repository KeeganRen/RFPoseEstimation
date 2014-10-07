function train_ps3d()

%% load data
imagedir = '../dataset/VideoClip3D/';

load('../data/model_football5907.mat');

% Load Camera calibration
C = 3;
cameraData = load([imagedir 'cameras.txt']);
nFrames = length(cameraData) / 2 / 4 / C;
cameraData = permute(reshape(cameraData, 2, 4, C, nFrames), [1 3 2 4]);
M  = reshape(cameraData, [2*C 4 nFrames]);

% Load 2D annotation
pointsData = load([imagedir 'annotation.txt']);
nLandmarks = length(pointsData) / 2 / nFrames / C;
pointsData = permute(reshape( pointsData, 2, nLandmarks, nFrames, C), [1 4 2 3]);
Wgt = reshape(pointsData, [2*C nLandmarks nFrames]);

% Load Ground Truth 3D pose
points3DData = load([imagedir 'joints.txt']);
Xgt = reshape( points3DData, 3, nLandmarks, nFrames );

%% Extend data by rotating ground truth
nExtend = 10;
Xst = repmat(Xgt, [1 1 nExtend]);
for i=1:nFrames*nExtend
    angle = randn(1,3)*pi/10;
    m = makehgtform('xrotate',angle(1),'yrotate',angle(2),'zrotate',angle(3));
    m = m(1:3,1:3);
    Xst(:,:,i) = m * Xst(:,:,i);
end
Xst = cat(3, Xgt, Xst);

%% 3dps parameters
ps3d_params.nClusters = 6*ones(1,14);
ps3d_params.lambda = 0.01;
ps3d_params.pa = [2 3 9 10 4 5 8 9 13 13 10 11 0 13];
ps3d_model = ps_fit(permute(Xst, [2 1 3]), ps3d_params, true);

save('../data/model_ps3d.mat', 'ps3d_model');

