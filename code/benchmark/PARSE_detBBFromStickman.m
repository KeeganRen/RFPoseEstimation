function bb = PARSE_detBBFromStickman(stick, ign1, ign2)

stick = double(stick);

torso_center = [(stick(1,1)+stick(3,1))/2 (stick(2,1)+stick(4,1))/2]; %center [x y]
miny = min([stick(2,[1 10]) stick(4,[1 10]) torso_center(2)]); % min y of torso and head
maxy = max([stick(2,10) stick(4,10) torso_center(2)]); % max y of head and torso center
diffx = abs(miny-maxy)/0.9;
head_center = [(stick(1,10)+stick(3,10))/2 (stick(2,10)+stick(4,10))/2];
minx = (head_center(1)+torso_center(1))/2 - diffx/2;
maxx = (head_center(1)+torso_center(1))/2 + diffx/2;
bb = [minx miny maxx maxy];