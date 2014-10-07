%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [threshold auc] = calc_roc(prob, labels, filename, visible)

if nargin<4
    visible = true;
end

num = 500;
minThreshold = min(prob);
maxThreshold = max(prob);
dt = (maxThreshold-minThreshold)/num;
tpr = zeros(1, num);
fpr = zeros(1, num);

pInd = find(labels>0);
nInd = find(labels<=0);

for i=1:num
    curThreshold = minThreshold + (i-1)*dt;
    
    tpos = sum(prob(pInd) >= curThreshold);
    fneg = length(pInd) - tpos;

    tneg = sum(prob(nInd) < curThreshold);
    fpos = length(nInd) - tneg;

    tpr(i) = tpos/(tpos+fneg);
    fpr(i) = fpos/(tneg+fpos);
end

i = [];
[~, i(1)] = min(abs(tpr+fpr-1));
threshold(1) = minThreshold + (i(1)-1)*dt;

i(2) = find(tpr > 0.99,1,'last');
threshold(2) = minThreshold + (i(2)-1)*dt;

i(3) = find(tpr >= 1,1,'last');
threshold(3) = minThreshold + (i(2)-1)*dt;

auc = sum(-diff(fpr) .* conv(tpr,[0.5 0.5],'valid'));

if visible
    fig = figure();
    plot(fpr, tpr, '-b', 'LineWidth',2);
    grid on
    
    hold on
    for j=1:3
        plot(fpr(i(j)),tpr(i(j)),'x');
        text(fpr(i(j)),tpr(i(j)),['\uparrow Threshold: ' num2str(threshold(j))],'VerticalAlignment','Top')
    end
    hold off

    title(['Threshold: ' num2str(threshold) '  AUC: ' num2str(auc)]);
    
    drawnow;

    if nargin>=3 && ~isempty(filename)
        print(fig, '-r80', '-djpeg100', filename);
    end
end

end
