%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function H=circle(center,radius,NOP,style)
if (nargin <2),
 error('Please see help for INPUT DATA.');
elseif(nargin==2)
	NOP = 10;
	style='b-';
elseif (nargin==3)
    style='b-';
end;
THETA=linspace(0,2*pi,NOP);
RHO=ones(1,NOP)*radius;
[X,Y] = pol2cart(THETA,RHO);
X=X+center(1);
Y=Y+center(2);
H=plot(X,Y,style,'LineWidth',3);
