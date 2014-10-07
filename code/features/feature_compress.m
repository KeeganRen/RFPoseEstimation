%
%  resp = feature_compress(resp)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function resp = feature_compress(resp)

resp = int8(clamp(127 * resp, -127, 127));
