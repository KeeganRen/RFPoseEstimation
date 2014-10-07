function st_cluster

disp('Clustering synthetic test.');

rng('default');

figure(1);
clf();
set(gcf, 'Position', [50 50 1200 300]);

[x idx] = generate_data(600);
subplot(1,3,1);
visualize_clusters(x,idx);
title('data');

k = 3;

idx = kmeans(x, k);
subplot(1,3,2);
visualize_clusters(x,idx);
title('kmeans');

idx = spectral_cluster(exp(-dist2(x)), k, 20);
subplot(1,3,3);
visualize_clusters(x,idx);
title('spectral clustering');

end

function [x idx] = generate_data(n)

p = floor(n/3);

r = rand(p,1);
t = rand(p,1).*2*pi;

x = [(r+1).*sin(t) (r+1).*cos(t);
    (r+5).*sin(t) (r+5).*cos(t);
    (r+10).*sin(t) (r+10).*cos(t);];

idx = [ones(p,1); ones(p,1)*2; ones(p,1)*3];

end

function visualize_clusters(x, idx)

colors = ['r','g','b','k','c'];
hold on
for i=unique(idx)'
    sel = find(i==idx);
    plot(x(sel,1), x(sel,2), ['.' colors(i)]);
end
hold off

end

