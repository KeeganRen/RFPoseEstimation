%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function visualize_point_features(im, points, pointSize)

if nargin<3
    pointSize = 10;
end

colors = [];

imd = im2double(im);

r = imd(:,:,1);
if size(im,3)>1
    g = imd(:,:,2);
    b = imd(:,:,3);
else
    g = imd(:,:,1);
    b = imd(:,:,1);
end

inds = sub2ind([size(im,1) size(im,2)], points(:,2), points(:,1));

colors(:,1) = r(inds);
colors(:,2) = g(inds);
colors(:,3) = b(inds);

imshow(zeros(size(im)));
hold on
scatter(points(:,1), points(:,2), pointSize, colors, 'filled');
hold off
