%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function a = sigmoid(z)

a = 1.0 ./ (1.0 + exp(-z));
