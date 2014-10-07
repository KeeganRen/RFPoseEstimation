function ptsAll = PARSE_26to14(ptsAll26)

partIDs = [14 12 10 22 24 26 7 5 3 15 17 19 2 1];
ptsAll = zeros(14,2,size(ptsAll26,3));
for i = 1:size(ptsAll26,3)
  ptsAll(:,:,i) = ptsAll26(partIDs,:,i);
end

end

