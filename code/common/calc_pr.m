%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function auc = calc_pr(prob, labels, filename, visible)

if nargin<4
    visible = true;
end

num = 500;
minThreshold = min(prob);
maxThreshold = max(prob);
dt = (maxThreshold-minThreshold)/num;
precision = zeros(1, num);
recall = zeros(1, num);

pInd = find(labels>0);
nInd = find(labels<=0);

for i=1:num
    curThreshold = minThreshold + (i-1)*dt;
    
    tpos = sum(prob(pInd) >= curThreshold);
    fneg = length(pInd) - tpos;

    tneg = sum(prob(nInd) < curThreshold);
    fpos = length(nInd) - tneg;

    precision(i) = tpos/(tpos+fpos);
    recall(i) = tpos/(tneg+fneg);
end

auc = sum(-diff(recall) .* conv(precision,[0.5 0.5],'valid'));

if visible
    fig = figure();
    plot(recall, precision, '-b', 'LineWidth',2);
    grid on  
    drawnow;

    if nargin>=3 && ~isempty(filename)
        print(fig, '-r80', '-djpeg100', filename);
    end
end

end
