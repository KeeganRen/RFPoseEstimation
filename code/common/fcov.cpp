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
    if(nlhs!=1 || nrhs!=2){
        mexErrMsgTxt("Usage: var = fcov(X, Y)\n");
    }
    
	Matrixf X(const_cast<mxArray*>(prhs[0]));	
    Matrixf Y(const_cast<mxArray*>(prhs[1]));	
	if( X.ndim != 2 || Y.ndim != 2){
        mexErrMsgTxt("Invalid data format.");
    }
        
    double N = (double)X.size[0];
    int D = std::max(X.size[1], Y.size[1]);
    
    int size[] = {1, D};
    Matrixf cov(2, size);
    
    #pragma omp parallel for
    for(int d=0; d<D; ++d)
    {
        double* Xd = &X.at(0, d%X.size[1]);
        double* Yd = &Y.at(0, d%Y.size[1]);
        
        double EX = 0;
        double EY = 0;
        double EXY = 0;

        for(int i=0; i<X.size[0]; ++i)
        {
            EX += Xd[i];
            EY += Yd[i];
            EXY += Xd[i]*Yd[i];
        }

        EX /= N;
        EY /= N;
        EXY /= N;

        cov[d] = EXY - EX * EY;
    }
    	
    plhs[0] = cov.arr;
}
