%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [scaled_data, params] = scale_data(data, params, method, inv)

if nargin<2, params = []; end;
if nargin<3 || isempty(method), method = 'linear'; end;
if nargin<4 || isempty(inv), inv = false; end;

if isempty(params)
    if(strcmp(method,'center'))
        params.scale = ones(1,size(data,2));
        params.shift = -mean(data);
    elseif(strcmp(method,'linear'))
        max_vec = full(max(data));
        min_vec = full(min(data));            
        params.scale = 1./(max_vec-min_vec);
        params.shift = -min_vec.*params.scale;
    elseif(strcmp(method,'std'))
        params.scale = 1./std(data);
        params.shift = -mean(data).*params.scale;
    else
        error('unknown method!');
    end
end

if inv
    iscale = 1./params.scale;
    scaled_data = bsxfun(@plus, bsxfun(@times, data, iscale), -params.shift.*iscale);
else
    scaled_data = bsxfun(@plus, bsxfun(@times, data, params.scale), params.shift);
end
