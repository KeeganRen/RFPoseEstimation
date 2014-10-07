//
//  Created by Vahid Kazemi
//  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
//
#include <math.h>
#include <algorithm>
#include <mex.h>
#include "tools.h"

int* doubleToInt(double *darr, int size)
{
    int *iarr = new int[size];
    for(int k=0; k<size; k++){        
        iarr[k] = (int)darr[k];
    }
    return iarr;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if(nrhs!=1){
        printf("Invalid number of inputs.\n");
        return;
    }
    
    if(nlhs!=1){
        printf("Invalid number of outputs.\n");
        return;
    }
    
	Matrixf _gsize(const_cast<mxArray*>(prhs[0]));    
    int *gsize = doubleToInt(_gsize.ptr, _gsize.length);

    // calculate the size
    int n = 1;
    for(int k=0; k<_gsize.length; k++){
        n *= gsize[k];
    }    
    
    // fill grid
    int gmsize[] = {n, _gsize.length};
    Matrixf grid(2, gmsize);
    int d = 1;
    for(int k=0; k<_gsize.length; k++){
        for(int i=0; i<n; i++){
            grid.at(i, k) = (i/d) % gsize[k] + 1;
        }
        d *= gsize[k];
    }
	
    plhs[0] = grid.arr;
    
    delete [] gsize;
}
