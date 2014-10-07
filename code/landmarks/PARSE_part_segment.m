function ims = PARSE_part_segment(sz, pts, len, radius)

if nargin < 3 || isempty(len), len = 1.3; end
if nargin < 4 || isempty(radius), radius = 8; end

% add an additional stick for the torso
bt0 = mean([pts(3,:); pts(4,:)]);
tt0 = mean([pts(9,:); pts(10,:)]);
bt1 = mean([pts(3,:); bt0]);
tt1 = mean([pts(9,:); tt0]);
bt2 = mean([pts(4,:); bt0]);
tt2 = mean([pts(10,:); tt0]);
pts = [pts; bt0; tt0; bt1; tt1; bt2; tt2];

% extend arms, and legs
pts(7,:) = pts(7,:) + (pts(7,:) - pts(8,:))*0.5;
pts(12,:) = pts(12,:) + (pts(12,:) - pts(11,:))*0.5;
pts(1,:) = pts(1,:) + (pts(1,:) - pts(2,:))*0.1;
pts(6,:) = pts(6,:) + (pts(6,:) - pts(5,:))*0.1;
pts(14,:) = pts(14,:) + (pts(14,:) - pts(13,:))*0.1;

nParts = 10;

allSticks = cell(1,nParts);
allSticks{1} = [1, 2]; % left lower leg
allSticks{2} = [5, 6]; % right lower leg
allSticks{3} = [2, 3]; % left upper leg
allSticks{4} = [4, 5]; % right upper leg
allSticks{5} = [7, 8]; % left lower arm
allSticks{6} = [11,12]; % right lower arm
allSticks{7} = [8, 9]; % left upper arm
allSticks{8} = [10,11]; % right upper arm
allSticks{9} = [13,14]; % head
allSticks{10} = [3,9;4,10;15,16;17,18;19,20;16,13]; % torso

rs = [1,1,1.4,1.4,1,1,1.2,1.2,1.4,1];


ims = logical(zeros(sz(1), sz(2), nParts));

for p = 1:nParts
    % generate a mask for the image
    sticks = allSticks{p};
    im = zeros(sz(1), sz(2));
        
    for j=1:size(sticks,1)
        pt1 = pts(sticks(j,1),:);
        pt2 = pts(sticks(j,2),:);

        center = mean([pt1; pt2]);
        dpt = pt2 - pt1;
        l = norm(dpt,2) * len;
        theta = -atan2(dpt(1), dpt(2));

        r = radius*rs(p);
        ss = 1.5;
        spts = make_grid(round([2*r*ss l*ss]));
        spts(:,1) = spts(:,1)*(1/ss) - r;
        spts(:,2) = spts(:,2)*(1/ss) - ceil(l*0.5);
        n = size(spts,1);

        mat = [ cos(theta) -sin(theta) center(1);
            sin(theta)  cos(theta) center(2)]';

        spts = floor([spts ones(n,1)] * mat);

        inds = sub2ind(sz, clamp(spts(:,2),1,sz(1)), clamp(spts(:,1),1,sz(2)));
        im(inds) = 1;
    end
    
    ims(:,:,p) = im;
end

end

function v = clamp(v, minv, maxv)
v = min(max(v, minv), maxv);
end
