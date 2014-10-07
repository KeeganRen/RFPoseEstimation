%
%  [best_pts, conf] = ps_match(points, weights, model)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [best_pts, conf, best_ws] = ps_match(points, weights, model)

params = model.params;
nLandmarks = length(points);
nDims = size(points{1},2);

scores = cell(1, nLandmarks);
inds = cell(1, nLandmarks);
coms = cell(1, nLandmarks);
for ch=1:nLandmarks
    pa = params.pa(ch);    
    nch = size(points{ch},1);
    if pa~=0
        npa = size(points{pa},1);
        inds{ch} = zeros(npa, params.nClusters(pa));
        coms{ch} = zeros(npa, params.nClusters(pa));
    end
    scores{ch} = repmat(model.bi{ch},[nch 1])*model.coef.com_unary(ch) +...
                 repmat(weights{ch}*model.coef.app(ch),[1 params.nClusters(ch)]);
end

% message passing
for l=1:nLandmarks    
    ch = params.up(l);
    pa = params.pa(ch);    
    
    if pa==0, continue; end
    
    mean = shiftdim(model.psi{ch}.mean, -1);
    ivar = shiftdim(model.psi{ch}.ivar, -1);
    
    nch = size(points{ch},1);
    npa = size(points{pa},1);
    
    % calculate compatibility score
    % msg: nch * nClusters_ch * nClusters_pa
    msg0 = repmat(scores{ch}, [1 1 params.nClusters(pa)]) +...
        repmat(shiftdim(model.bij{ch}*model.coef.com_pair(ch),-1), [nch 1]);
    
    for ipa = 1:npa
        % calculate deformation score
        dp = bsxfun(@minus, points{pa}(ipa,:), points{ch});
        defscore = -sum(bsxfun(@times, bsxfun(@minus, dp, mean).^2, ivar),2) * model.coef.def(ch);
        defscore = reshape(defscore, [nch params.nClusters(ch) params.nClusters(pa)]);
        msg = msg0 + defscore;
        for j=1:params.nClusters(pa)
            msg_j = msg(:,:,j);
            [max_val, max_ind] = max(msg_j(:));
            [max_n, max_com] = ind2sub(size(msg_j), max_ind);
            scores{pa}(ipa,j) = scores{pa}(ipa, j) + max_val;
            inds{ch}(ipa,j) = max_n;
            com{ch}(ipa,j) = max_com;
        end
    end
end

% backtrack
best_pts = zeros(nLandmarks, nDims);
best_ind = zeros(nLandmarks, 1);
best_com = zeros(nLandmarks, 1);
best_ws  = zeros(nLandmarks, 1);

down = params.up(end:-1:1);

root = down(1);

[conf, ind] = max(scores{root}(:));
[max_n, max_com] = ind2sub(size(scores{root}), ind);
best_pts(root,:) = points{root}(max_n, :);
best_ind(root) = max_n;
best_com(root) = max_com;
best_ws(root) = weights{root}(max_n);

for l=2:nLandmarks
    ch = down(l);
    pa = params.pa(ch);    
    
    max_n = inds{ch}(best_ind(pa), best_com(pa)); 
    max_com = com{ch}(best_ind(pa), best_com(pa));
    
    best_pts(ch,:) = points{ch}(max_n, :);
    best_ind(ch) = max_n;
    best_com(ch) = max_com;
    best_ws(ch) = weights{ch}(max_n);
end
