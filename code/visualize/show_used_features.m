%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function show_used_features

load ../data/forest_football5907.mat

depths = [10 11 12 13 14 20];
nD = length(depths);
nT = length(trees);

figure(1);
set(1, 'Position', [0, 0, 1024, 700]*0.6);

for d = 1:nD
    res = zeros(20,20,nT);    
    for t=1:nT
        n = (2^(depths(d) - 1))-1;
        nodes = trees(t).nodes(1:n,:);
        %sel = sum(trees(t).hists(1:n,:),2) > 0;
        %res(:,:,t) = hist3(nodes(sel,1:2),[20 20]);
        res(:,:,t) = hist3(nodes(:,1:2),[20 20]);
    end    
    tightplot(2,nD/2,d, 0.03, 0.75);
    imagesc(mean(res,3));
    title(sprintf('Depth 1-%d', depths(d)));
    axis off
end

drawnow;
export_fig('../result/used_features.pdf','-transparent');
