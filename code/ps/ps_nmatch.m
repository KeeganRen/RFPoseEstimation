%
%  [all_best_pts, all_conf, all_scores] = ps_nmatch(points, weights, model)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [all_best_pts, all_conf, all_scores] = ps_nmatch(points, weights, model)

params = model.params;
nLandmarks = length(points);

inds_up = cell(1, nLandmarks);
inds_down = cell(1, nLandmarks);
coms_up = cell(1, nLandmarks);
coms_down = cell(1, nLandmarks);
msg_up = cell(1, nLandmarks);
msg_down = cell(1, nLandmarks);
scores = cell(1, nLandmarks);
for ch=1:nLandmarks
    pa = params.pa(ch);    
    nch = size(points{ch},1);
    if pa~=0
        npa = size(points{pa},1);
        inds_up{ch} = zeros(npa, params.nClusters(pa));
        inds_down{ch} = zeros(nch, params.nClusters(ch));
        coms_up{ch} = zeros(npa, params.nClusters(pa));
        coms_down{ch} = zeros(nch, params.nClusters(ch));
        msg_up{ch} = zeros(npa, params.nClusters(pa));
        msg_down{ch} = zeros(nch, params.nClusters(ch));
    end
    scores{ch} = repmat(model.bi{ch},[nch 1])*model.coef.com_unary(ch) +...
                 repmat(weights{ch}*model.coef.app(ch),[1 params.nClusters(ch)]);
end

% message passing bottom up
for l=1:nLandmarks    
    ch = params.up(l);
    pa = params.pa(ch);    
    
    if pa==0, continue; end
    
    mean = shiftdim(model.psi{ch}.mean, -1);
    ivar = shiftdim(model.psi{ch}.ivar, -1);
    
    nch = size(points{ch},1);
    npa = size(points{pa},1);
    
    % msg0: appearance score + compatibility score
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
            inds_up{ch}(ipa,j) = max_n;
            coms_up{ch}(ipa,j) = max_com;
            msg_up{ch}(ipa, j) = max_val;
        end
    end
    scores{pa} = scores{pa} + msg_up{ch};
end

% message passing top down
for l=1:nLandmarks    
    ch = params.down(l);
    pa = params.pa(ch);    
    
    if pa==0, continue; end
    
    mean = shiftdim(model.psi{ch}.mean, -1);
    ivar = shiftdim(model.psi{ch}.ivar, -1);
    
    nch = size(points{ch},1);
    npa = size(points{pa},1);
    
    % msg0: appearance score + compatibility score
    msg0 = repmat(reshape(scores{pa}-msg_up{ch},...
        [npa 1 params.nClusters(pa)]),[1 params.nClusters(ch) 1]) +...
        repmat(shiftdim(model.bij{ch}*model.coef.com_pair(ch),-1), [npa 1]);
    
    for ich = 1:nch
        % calculate deformation score
        dp = bsxfun(@minus, points{pa}, points{ch}(ich,:));
        defscore = -sum(bsxfun(@times, bsxfun(@minus, dp, mean).^2, ivar),2) * model.coef.def(ch);
        defscore = reshape(defscore, [npa params.nClusters(ch) params.nClusters(pa)]);
        msg = msg0 + defscore;
        for j=1:params.nClusters(ch)
            msg_j = msg(:,j,:);
            [max_val, max_ind] = max(msg_j(:));
            [max_n, ~, max_com] = ind2sub(size(msg_j), max_ind);
            inds_down{ch}(ich,j) = max_n;
            coms_down{ch}(ich,j) = max_com;
            msg_down{ch}(ich,j) = max_val;
        end
    end
    scores{ch} = scores{ch} + msg_down{ch};
end

% for each root
all_best_pts = [];
all_conf = [];
if nargout>2
    all_scores = struct(...
                'app', zeros(nch,nLandmarks),...
                'def', zeros(nch,nLandmarks),...
                'com_unary',zeros(nch,nLandmarks),...
                'com_pair',zeros(nch,nLandmarks));
end

for root=1:nLandmarks        
    [newpa, neworder, inv] = reorder(params.pa, params.down, root);
    
    % back-track to get the whole configuration
    nch = size(points{root},1);
    best_pts = zeros(nLandmarks, 2, nch);
    best_ind = zeros(nLandmarks, nch);
    best_com = zeros(nLandmarks, nch);
    
    [conf, 	max_com] = max(scores{root},[],2);
    best_pts(root, :, :) = points{root}';
    best_ind(root, :) = 1:nch;
    best_com(root, :) = max_com;
    
    for l=2:nLandmarks
        ch = neworder(l);
        pa = newpa(ch);
        if(inv(ch))
            index = sub2ind(size(inds_down{pa}), best_ind(pa,:), best_com(pa,:));
            max_n = inds_down{pa}(index);
            max_com = coms_down{pa}(index);
        else
            index = sub2ind(size(inds_up{ch}), best_ind(pa,:), best_com(pa,:));
            max_n = inds_up{ch}(index);    
            max_com = coms_up{ch}(index);
        end        
        best_pts(ch,:,:) = points{ch}(max_n, :)';
        best_ind(ch,:) = max_n;
        best_com(ch,:) = max_com;
    end    
    
    all_best_pts = cat(3, all_best_pts, best_pts);
    all_conf = cat(1, all_conf, conf);
    
    if nargout>2
        best_scores = struct(...
            'app', zeros(nch,nLandmarks),...
            'def', zeros(nch,nLandmarks),...
            'com_unary',zeros(nch,nLandmarks),...
            'com_pair',zeros(nch,nLandmarks));        
        for ch=1:nLandmarks
            pa = params.pa(ch);
            best_scores.app(:,ch) = weights{ch}(best_ind(ch,:));
            best_scores.com_unary(:,ch) = model.bi{ch}(best_com(ch,:));
            if pa~=0
                sz = [2 params.nClusters(ch) params.nClusters(pa)];
                ix = sub2ind(sz,1*ones(nch,1), best_com(ch,:)', best_com(pa,:)');
                iy = sub2ind(sz,2*ones(nch,1), best_com(ch,:)', best_com(pa,:)');
                mean = [model.psi{ch}.mean(ix) model.psi{ch}.mean(iy)];
                ivar = [model.psi{ch}.ivar(ix) model.psi{ch}.ivar(iy)];
                dp = points{pa}(best_ind(pa,:),:) -  points{ch}(best_ind(ch,:),:);
                best_scores.def(:,ch) = (-sum(ivar.*(dp-mean).^2,2) * model.coef.def(ch));
                best_scores.com_pair(:,ch) = model.bij{ch}(sub2ind(size(model.bij{ch}), best_com(ch,:), best_com(pa,:)));
            end
        end
        all_scores.app = cat(1, all_scores.app, best_scores.app);
        all_scores.def = cat(1, all_scores.def, best_scores.def);
        all_scores.com_unary = cat(1, all_scores.com_unary, best_scores.com_unary);
        all_scores.com_pair = cat(1, all_scores.com_pair, best_scores.com_pair);
    end
end


[all_conf,all_inds] = unique(all_conf, 'sorted');
all_conf = all_conf(end:-1:1);
all_inds = all_inds(end:-1:1);
all_best_pts = all_best_pts(:,:,all_inds); 

if nargout>2
    all_scores.app = all_scores.app(all_inds,:);
    all_scores.def = all_scores.def(all_inds,:);
    all_scores.com_unary = all_scores.com_unary(all_inds,:);
    all_scores.com_pair = all_scores.com_pair(all_inds,:);
end

end


function [newpa, neworder, inv] = reorder(parents, order, root)
% reorder indices so that root is first
newpa = parents;
newpa(root) = 0;
neworder = root;
nLandmarks = length(parents);
inv = false(1,nLandmarks);
inv(root) = ~(parents(root)==0);
ch = root;
pa = parents(ch);
while pa~=0
    neworder = [neworder pa];
    newpa(pa) = ch;
    inv(pa) = true;
    ch = pa;
    pa = parents(ch);
end
neworder = [neworder setdiff(order, neworder, 'stable')];
end
