%
%  gmm_likelihood(obj, X)
%
%  returns [sum of likelihoods, max of likelihoods, cluster index]
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [like maxl ind]  = gmm_likelihood(obj, X)

k = size(obj.Mu,1);
for j=1:k
    like(:,j) = obj.Pi(j)*mvnpdf(X,obj.Mu(j,:),obj.Sigma(:,:,j));
end
[maxl ind] = max(like,[],2);

end
