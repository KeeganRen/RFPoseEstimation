function print_final_results()

load ../data/results_football5907.mat
load ../data/results_football5907_FMP.mat

fmpPts = zeros(14, 2, 2007);
for i=1:2007
    pts26 = reshape(points{i}(1,:), [2 26])';
    fmpPts(:,:,i) = PARSE_26to14(pts26);
end

fprintf('Head & Torso & UArms & LArms & ULegs & LLegs & Average\n');

[detRate PCP R] = PARSE_eval_pcp(fmpPts, gtPts);
fprintf('FMP\n');
print_part_results(detRate*R);

[detRate PCP R] = PARSE_eval_pcp(msPts, gtPts);
fprintf('RF+Max\n');
print_part_results(detRate*R);

[detRate PCP R] = PARSE_eval_pcp(psPts, gtPts);
fprintf('RF+DP\n');
print_part_results(detRate*R);

[detRate PCP R] = PARSE_eval_pcp(oraclePts, gtPts);
fprintf('RF+Oracle\n');
print_part_results(detRate*R);

end

function print_part_results(scores)
scores = round(scores*100)/100;
head = 10;
torso = 1;
uarm = [6 7];
larm = [8 9];
uleg = [2 3];
lleg = [4 5];
fprintf('%.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f\n',...
    mean(scores(head)), mean(scores(torso)),...
    mean(scores(uarm)), mean(scores(larm)), ...
    mean(scores(uleg)), mean(scores(lleg)), ...
    mean(scores));
end
