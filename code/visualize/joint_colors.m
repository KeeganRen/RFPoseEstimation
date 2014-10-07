%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function colors = joint_colors(nColors)

if nColors==14
	colors = [...
		1,0,1;  % Left Ankle
		1,0,0;  % Left Knee
		0,1,0;  % Left Hip
		0,0,1;  % Right Hip
		1,0,1;  % Right Knee
		1,0,0;  % Right Angkle
		
		1,0.5,0;  % Left Hand
		0,0,1;  % Left Elbow
		1,1,0;  % Left Shoulder
		0,1,1;  % Right Shoulder
		1,0,1;  % Right Elbow
		1,1,0;  % Right Hand
		
		1,0.3,0;  % Lower head
		1,0,0]; % Upper head
else
	colors = hsv(nColors);
end


