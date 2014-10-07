%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function ll = lmvnpdf(X, Mu, Sigma)

[n,d] = size(X);

X = X - repmat(Mu,[n,1]);

[U,D,V] = svd(Sigma);
IS = U*diag(1./diag(D))*V';
EX = sum((X * IS) .* X,2);

ld = sum(log(abs(diag(D))));
ll = -0.5*(d*log(2*pi) + ld + EX);

end
