%
%  make
%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
function make(folder, filename)

if nargin==0, folder = '.'; end

if nargin==2
    names = {filename};
else
    files = dir([folder '/*']);
    for i=1:length(files)
        if files(i).isdir && files(i).name(1)~='.'
            make([folder '/' files(i).name]);
        end
    end

    files = dir([folder '/*.cpp']);
    names = cell(1, length(files));
    for i=1:length(files)
        names{i} = files(i).name;
    end
end

for i=1:length(names)
    input = [folder '/' names{i}];
    output = [input(1:end-3) mexext];

    if exist(output,'file')
        if getfield(dir(input), 'datenum') < getfield(dir(output), 'datenum')
            continue;
        end
    end

    if ispc
        cflags = '/Ox /openmp';
        lflags = '';
        include = '-Icommon';
        libs = '';
        str = ['mex -O COMPFLAGS="$COMPFLAGS ' cflags '" ' include ' LINKFLAGS="$LINKFLAGS ' lflags '" ' input ' ' libs ' -output ' output];
    else
        cflags = '-march=native -std=c++0x -fopenmp';
        lflags = '-w -fopenmp';
        include = '-Icommon';
        libs = '';
        str = ['mex -O CXXFLAGS="\$CXXFLAGS ' cflags '" ' include ' LDFLAGS="\$LDFLAGS ' lflags '" ' input ' ' libs ' -output ' output];
    end
    
    try
        disp(['Compiling ' names{i} '...']);
        eval(str);
    catch err
        disp(err.message);
        disp('That did not work out.');
    end
end
