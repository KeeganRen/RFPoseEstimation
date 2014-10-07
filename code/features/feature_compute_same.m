%
%  scaled = feature_compute_ex(feat, sz)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function outfeat = feature_compute_same(im, params)

im = double(im);

switch params.type
    case 'HOG'
        im = padarray(im, [params.sbin params.sbin 0], 'symmetric');
        feat = hog(im, params.sbin);

        nFilters = size(feat,3);
        sz = size(im);

        outfeat = zeros(sz(1), sz(2), nFilters);

        for i=1:nFilters
            sfeat = imresize(feat(:,:,i), sz(1:2));
            sfeat = sfeat(1:sz(1), 1:sz(2), :);
            outfeat(:,:,i) = sfeat;
        end
        
    case 'Color'
        outfeat = im*(1/255);
        
    case 'HOGColor'
        im = padarray(im, [params.sbin params.sbin 0], 'symmetric');
        feat = hog(im, params.sbin);

        nFilters = size(feat,3);
        sz = size(im);

        outfeat = zeros(sz(1), sz(2), nFilters+3);

        for i=1:nFilters
            sfeat = imresize(feat(:,:,i), sz(1:2));
            sfeat = sfeat(1:sz(1), 1:sz(2), :);
            outfeat(:,:,i) = sfeat;
        end
        
        outfeat(:,:,end-2:end) = im*(1/255);
end
