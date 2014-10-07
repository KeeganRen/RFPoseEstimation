%
%  resps = feature_convolve(feat, filters, sz)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function resps = feature_convolve(feat, filters, sz)

if nargin>2
    offset = round([size(filters,1) size(filters,2)] / 2);
    feat = padarray(feat, [offset 0]);
end

resps = fconv(feat, filters);

if nargin>2 && any(sz(1:2)~=[size(resps,1) size(resps,2)])
    nFilters = size(resps,3);
    scaled = zeros(sz(1), sz(2), nFilters);
    for i=1:nFilters
        scaled(:,:,i) = imresize(resps(:,:,i), sz(1:2));
    end
    resps = scaled;
end
