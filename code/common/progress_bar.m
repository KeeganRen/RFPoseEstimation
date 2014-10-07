%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function cp = progress_bar(cp, val, count)
%PROGRESS_BAR displays a progress bar in console
%   CP: internal variable should be set to zero at start
%   VAL: current estimate of progress
%   COUNT: maximum progress value
% 
%   sample usage:
%
%	cp = 0;
%   for i=1:100
%       cp = progress_bar(cp, i, 100);
%   end

if (val<0)
    disp('the value should start from 1.');
elseif (val>count)
    disp('the value has passed the maximum number');
end

len = 40;

if (cp==0)
    fprintf(1, [char(ones(1,len)*'_') '\n']);
end

cval = max(1, floor(len*val/count));
if cp<cval
    fprintf(1, char(ones(1,cval-cp)*'X'));
    cp = cval;
end

if (val==count)
    fprintf(1,'\n');
    disp('progress completed.');
end
    
end
