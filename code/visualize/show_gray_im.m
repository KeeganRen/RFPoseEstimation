%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function show_gray_im(im)

assert(size(im,3)==1);

imshow((im-min(im(:)))/(max(im(:))-min(im(:))));
