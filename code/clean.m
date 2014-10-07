%
%  clean(folder, filename)
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function clean(folder, filename)

if nargin==0, folder = '.'; end

if nargin==2
    names = {filename};
else
    files = dir([folder '/*']);
    for i=1:length(files)
        if files(i).isdir && files(i).name(1)~='.'
            clean([folder '/' files(i).name]);
        end
    end

    files = dir([folder '/*.' mexext]);
    names = cell(1, length(files));
    for i=1:length(files)
        names{i} = files(i).name;
    end
end

for i=1:length(names)
    input = [folder '/' names{i}];
    delete(input);
end

