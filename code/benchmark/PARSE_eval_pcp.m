function [detRate PCP R] = PARSE_eval_pcp(points,gtpoints, thresh)

if nargin < 3
    thresh = 0.5;
end

% -------------------
% create groundtruth stick
% because FOOTBALL dataset do not have grountruth stick labels, we create the
% groundtruth stick labels by ourselves using groundtruth keypoints
I = [1   1   2   2   3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20];
J = [9   10  3   4   3 2 4 5 2 1 5 6  9  8  10 11 8  7  11 12 14 13];
S = [1/2 1/2 1/2 1/2 1 1 1 1 1 1 1 1  1  1  1  1  1  1  1  1  1  1];
A = full(sparse(I,J,S,20,14));

for n = 1:size(gtpoints,3)
    predstick(n).stickmen.coor = reshape((A*points(:,:,n))',4,10);
    gtstick(n).stickmen.coor = reshape((A*gtpoints(:,:,n))',4,10);
end

% the PCP evaluation function originally comes from BUFFY dataset, we keep using that for performance evaluation
% OLD
%[detRate PCP R] = eval_pcp('PARSE',predstick,gtstick);
% NEW
[detRate PCP R] = eval_pcp(@PARSE_detBBFromStickman,predstick,gtstick, thresh);

