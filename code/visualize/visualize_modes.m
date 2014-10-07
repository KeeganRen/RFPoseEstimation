%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function visualize_modes(im, points, weights, width)

if nargin<4
    width = 1;
end

if ~isempty(im)
    imshow(im);
end

colors = joint_colors(length(points));

hold on
for p=1:length(points)
    scatter(points{p}(:,1), points{p}(:,2), 100*width*exp(weights{p}), colors(p,:), 'filled');
end
hold off

end
