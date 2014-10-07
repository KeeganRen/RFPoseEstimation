%
%  feat = feature_compute(im, params)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function feat = feature_compute(im, params)

im = double(im);

switch params.type
    case 'HOG'
        im = padarray(im, [params.sbin params.sbin 0], 'symmetric');
        feat = hog(im, params.sbin);
    case 'Intensity'
        feat = imresize(im, 1/params.subsample)*(1/255);
    otherwise
        disp('Unknown feature type.');
end

