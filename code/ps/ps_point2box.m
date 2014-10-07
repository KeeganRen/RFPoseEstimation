%
%  [points partSizes] = ps_point2box(imageDir, visualize)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [points partSizes] = ps_point2box(imageDir, visualize)

if nargin<2, visualize = false; end

load([imageDir 'labels.mat']);
files = dir([imageDir '*.jpg']);

% read annotation
nNumImages = size(ptsAll,3);
nLandmarks = size(ptsAll,1);

% calculate bounding boxes
numParts = 10;
partPoints = {[13; 14] [3 4; 9 10]...
    [ 8;  9] [ 7;  8] [2; 3] [1; 2]...
    [11; 10] [12; 11] [5; 4] [6; 5]};

partSizes = [...
    1.0, 0.6; % head
    1.0, 0.5; % torso
    1.0, 0.4; % upper arm
    1.0, 0.3; % lower arm
    1.0, 0.4; % upper leg
    1.0, 0.3; % lower leg
    1.0, 0.4; % upper arm
    1.0, 0.3; % lower arm
    1.0, 0.4; % upper leg
    1.0, 0.3];% lower leg

points = zeros(numParts, 4, nNumImages);
disp('calculating bounding boxes...');
for i=1:nNumImages
    [pos angle scl lpos] = get_part_points([ptsAll(:,2,i) ptsAll(:,1,i)], partPoints, partSizes);
    for j=1:numParts
        points(j,:,i) = [pos(j,:) angle(j,:) scl(j,:)];
    end
end

% find mean pose
disp('normalizing the partSizes...');
for j=1:numParts
    mean_scale = mean(points(j,4,:));
    points(j,4,:) = round(points(j,4,:) / mean_scale);
    partSizes(j,:) = round(partSizes(j,:) * mean_scale);
end

% visualize mean image
if visualize
    disp('creating the mean image...');
    % allocate all the parts
    sim = cell(1, numParts);
    for i=1:numParts, sim{i} = zeros(partSizes(i,1), partSizes(i,2), 3); end;
    
    % go through all the images
    pb = 0;
    for n=1:nNumImages
        % load the image
        im = double(imread([imageDir files(n).name]));
        
        for i=1:numParts
            % crop the bounding box
            cim = crop_obb(im, points(i,1:2,n), partSizes(i,:), points(i,3,n));
            % resize to mean scale
            sz = size(cim);
            if(~prod(double(sz(1,1:2)==partSizes(i,:))))
                cim = imresize(cim, partSizes(i,:));
            end
            % store all the values
            sim{i} = sim{i} + cim;
        end
        pb = progress_bar(pb, n, nNumImages);
    end
    
    % take the mean of parts
    for i=1:numParts, sim{i} = sim{i}/nNumImages; end;
    
    % paste mean parts on a blank image
    pos = [50 80; 120 80; ...
        110 25; 180 25; 210 60; 290 60;...
        110 135; 180 135; 210 100; 290 100];
    im = ones(350,160,3);
    for i=1:numParts
        im = paste_image(im, sim{i}, pos(i,:));
    end
    imshow(im*2);
end
disp('done.');

end

function [pos angle scale lpos] = get_part_points(pts, partPoints, partSizes)

numParts = length(partPoints);
pos = zeros(numParts,2);
scale = zeros(numParts,1);
angle = zeros(numParts,1);
lpos = zeros(size(pts,1),2);

for i=1:numParts
    pos(i,:) = mean(pts(partPoints{i}(:),:),1);
    v = mean(pts(partPoints{i}(1,:),:),1) - mean(pts(partPoints{i}(2,:),:),1);
    angle(i) = -atan2(v(2), v(1));
    scale(i,:) = 1.5 * norm(v);
    
    for k=partPoints{i}(:)'
        T = inv(Transform.create('r', angle(i)) * Transform.create('s', partSizes(i,:)));
        lpos(k,:) = Transform.coords(pts(k,:)- pos(i,:), T);
    end
end

end
