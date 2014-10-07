function visualize_configuration_ex(im, pts, lines, width)

if nargin<3, lines = []; end
if nargin<4, width = 5; end

colors = limb_colors(size(lines,1));

if ~isempty(im)
    imshow(im,'border','tight');
end

hold on
if ~isempty(lines)
    for i=1:size(lines,1)
        for j=1:size(pts,3)
            plot(pts(lines(i,:),1,j), pts(lines(i,:),2,j), 'Color', colors(i,:), 'LineWidth', width);
        end
    end
end
hold off
drawnow;
