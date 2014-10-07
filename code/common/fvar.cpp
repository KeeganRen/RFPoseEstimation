//
//  Created by Vahid Kazemi
//  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
//

#include <math.h>
#include <algorithm>
#include <mex.h>
#include "tools.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if(nlhs!=1 || nrhs!=1){
        mexErrMsgTxt("Usage: var = fvar(X)\n");
    }
    
	Matrixf X(const_cast<mxArray*>(prhs[0]));	
	if( X.ndim != 2){
        mexErrMsgTxt("Invalid data format.");
    }
        
    double N = (double)X.size[0];
    int D = X.size[1];
    
    int size[] = {1, D};
    Matrixf var(2, size);
    
    #pragma omp parallel for
    for(int d=0; d<D; ++d)
    {
        double* Xd = &X.at(0, d%X.size[1]);
        
        double EX = 0;
        double EXX = 0;

        for(int i=0; i<X.size[0]; ++i)
        {
            EX += Xd[i];
            EXX += Xd[i]*Xd[i];
        }

        EX /= N;
        EXX /= N;

        var[d] = EXX - EX * EX;
    }
    	
    plhs[0] = var.arr;
}
