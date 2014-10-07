%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function [mi_im bbox] = mirror_pad_image(im, padding)

sz = size(im);

if nargin < 2
    padding = [sz(2) sz(1) sz(2) sz(1)];
end

bbox = [padding(1) + 1, padding(2) + 1, padding(1) + sz(2), padding(2) + sz(1)];

mi_im = zeros(sz(1) + padding(2) + padding(4), sz(2) + padding(1) + padding(3), sz(3));

% copy image to the center
mi_im(padding(2) + 1 : padding(2) + sz(1), padding(1) + 1 : padding(1) + sz(2), :) = im;

% copy top
mi_im(1 : padding(2), padding(1) + 1 : padding(1) + sz(2), :) = im(padding(2) : -1 : 1, :, :);

% copy bottom
mi_im(end - padding(4) + 1 : end, padding(1) + 1 : padding(1) + sz(2), :) = im(end : -1 : end - padding(4) + 1, :, :);

% copy left
mi_im(padding(2) + 1 : padding(2) + sz(1), 1 : padding(1), :) = im(:, padding(1) : -1 : 1, :);

% copy right
mi_im(padding(2) + 1 : padding(2) + sz(1), end - padding(3) + 1 : end, :) = im(:, end : - 1 : end - padding(3) + 1, :);

% copy top left
mi_im(1 : padding(2), 1 : padding(1), :) = im(padding(2) : -1 : 1, padding(1) : -1 : 1, :);

% copy top right
mi_im(1 : padding(2), end - padding(3) + 1 : end, :) = im(padding(2) : -1 : 1, padding(1) : -1 : 1, :);

% copy bottom right
mi_im(end - padding(4) + 1 : end, end - padding(3) + 1 : end, :) = im(padding(2) : -1 : 1, padding(1) : -1 : 1, :);

% copy bottom left
mi_im(end - padding(4) + 1 : end, 1 : padding(1), :) = im(padding(2) : -1 : 1, padding(1) : -1 : 1, :);

mi_im = uint8(mi_im);
