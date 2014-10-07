%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function visualize_configuration(im, pts, lines, width)

if nargin<3, lines = []; end
if nargin<4, width = 5; end

colors = joint_colors(size(pts,1));

if ~isempty(im)
    imshow(im,'border','tight');
end

hold on
if ~isempty(lines)
    for i=1:size(lines,1)
        for j=1:size(pts,3)
            plot(pts(lines(i,:),1,j), pts(lines(i,:),2,j), 'w', 'LineWidth', width);
            plot(pts(lines(i,:),1,j), pts(lines(i,:),2,j), 'k', 'LineWidth', 2);
        end
    end
end
for j=1:size(pts,3)
    scatter(pts(:,1,j), pts(:,2,j), width*25, colors, 'filled');
end
hold off
drawnow;
