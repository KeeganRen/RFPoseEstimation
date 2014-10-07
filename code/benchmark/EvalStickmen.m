function [evalNo, Score, Nannotparts, ScoreDetailed] = EvalStickmen(gtToBBfunc, stickmen_set, gt_stickman, pcp_matching_threshold)
% user interface to evaluate set of stickmen together with corresponding detection bounding boxes against one ground-truth stickman
% (single-image evaluation)
%
% Input:
% gtToBBfunc - function that generates ground-truth detections from gt_stickman annotations e.g. detBBFromStickmanPascal
% stickmen_set - (contains set of stickmen to be evaluated with the ground-truth stickman) is an struct array with fields: 
%       .coor - stickman end-points coordinates (:,nparts) = [x1 y1 x2 y2]'
%       .det - the detection bounding box associated with the stickman [minx miny maxx maxy]
%
%       if .det field doesn't exist, then for association purpose a detection bounding boxes will be generated for each element in stickmen_set 
%       in the same way as for groundtruth_stickman

% gt_stickman - (contains ground-truth stickman coordiantes) is a 1x1 struct:
%        .coor - containing ground-truth stickman end-points coordinates (:,nparts) = [x1 y1 x2 y2]' 
%
% pcp_matching_threshold (optional) - defines the PCP sticks matching threshold (default 0.5) -> for definition look into README.txt 
%
% Output:
% evalNo - index of the evaluated stickman that has been matched with the ground-truth stickman
% Score -  indicates the number of correctly estimated body parts in stickmen_set(evalNo)
%
% in case when none of the stickmen_set can be associated with the gt_stickman or stickmen_set is empty then evalNo = 0, Score = nan;
%
% the evaluation procedure stops as soon one of the stickmen_set is associated to the ground-truth annotation 
% (if two det windows from stickmen_set overlap by more than PASCAL criterion then evaluation stops reporting an error)

% Eichner/2009

if nargin < 4 
  pcp_matching_threshold  = 0.5;
end


pars.iou_thresh = 0.5;
classname = 'ubf';
pars.det_hwratio(2) = 0.9;

ScoreDetailed = cell(1);
Score = 0;
evalNo = 0;

if length(gt_stickman) ~= 1 || ~isfield(gt_stickman,'coor')
  error('gt_stickman must be a 1x1 struct with field .coor')
end

% number of annotate parts
Nannotparts = size(gt_stickman.coor,2);
ScoreDetailed{1} = zeros(Nannotparts,1);

if isempty(stickmen_set) || isempty(stickmen_set(1).coor)
  return;
end


N = length(stickmen_set);


% create the .det field if does not exist
if ~isfield(stickmen_set(1),'det')
 stickmen_set(1).det = []; % setting for one elements adds this field for whole array
end
for i=1:N
  if isempty(stickmen_set(i).det)
    % if detection was not provided then derive from stickman
    stickmen_set(i).det = gtToBBfunc(stickmen_set(i).coor,classname,pars);
  end
end

% no two of the provided detections may be overlaping by more than the PASCAL criterion
det_overlap = all_pairs_bb_iou(cat(1,stickmen_set(:).det)', cat(1,stickmen_set(:).det)');
det_overlap = ~eye(size(det_overlap)).*det_overlap; % remove elements from the diagonal
if any(det_overlap(:) > pars.iou_thresh)
  error('no two detections may overlap with each other by more than the PASCAL criterion !!!!');
end

% hallucinate detection window from the gt stickman
gt_bb = gtToBBfunc(gt_stickman.coor,classname,pars); % not rounded

for i=1:N 
  if all_pairs_bb_iou(gt_bb',  stickmen_set(i).det') > pars.iou_thresh % iou converts minmax to wh without + 1
    % evaluate only when eval_bb can be associated with gt_bb iou > 0.5
    % stop evaluation after first bb match
    evalNo = i; % so evalNo ~= 0 and stickman is taken into account when calculating PCP
    if isempty(stickmen_set(i).coor)
        disp('WARNING: the evaluated stickmen coor field is empty -> score 0');
    else
      [Score ScoreDetailed{1}] = DirectEvalStickman(stickmen_set(i).coor, gt_stickman.coor,pcp_matching_threshold);
    end
    return
  end
end

end
