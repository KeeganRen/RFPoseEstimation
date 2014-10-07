%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function make(filename)

flags = [];
%flags = '-DUSE_DOUBLE';

if nargin==1
    names = {filename};
else
    files = dir('*.cpp');
    names = cell(1, length(files));
    for i=1:length(files)
        names{i} = files(i).name;
    end
end

for i=1:length(names)
    disp(['compiling ' names{i} '...']);
    if ispc
        str = ['mex -O COMPFLAGS="$COMPFLAGS /Ox /openmp ' flags '" LINKFLAGS="$LINKFLAGS" ' names{i}];
    else
        str = ['mex -O CXXFLAGS="\$CXXFLAGS -march=native' flags ' -std=c++0x -fopenmp" LDFLAGS="\$LDFLAGS -w -fopenmp" ' names{i}];
    end
    disp(str);
    eval(str);
end

disp('done.');
