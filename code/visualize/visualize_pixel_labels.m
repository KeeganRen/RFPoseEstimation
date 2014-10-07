%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function final = visualize_pixel_labels(mask, exposure, gamma, colors, visualize)

sz = size(mask);
if nargin<2 || isempty(exposure), exposure = 1.5; end
if nargin<3 || isempty(gamma), gamma = 1.5; end
if nargin<4 || isempty(colors),
    colors = joint_colors(sz(3));
end
if nargin<5, visualize = true; end

colors = reshape(colors(1:sz(3),:)', [1 1 3 sz(3)]);

mask = reshape(mask, [sz(1) sz(2) 1 sz(3)]);
mask = repmat(mask, [1 1 3 1]);
mask = (exposure * mask).^gamma;

final = bsxfun(@times, mask, colors);
final = sum(final, 4);

if visualize
    imshow(final);
end

