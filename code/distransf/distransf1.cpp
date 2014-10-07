//
//  distransf1.cpp
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
    if(nrhs!=3){
        printf("Invalid number of inputs.\n");
        return;
    }
    
    if(nlhs!=2){
        printf("Invalid number of outputs.\n");
        return;
    }
    
	Matrixf f(const_cast<mxArray*>(prhs[0]));
    double mu = mxGetScalar(const_cast<mxArray*>(prhs[1]));
    double invd = mxGetScalar(const_cast<mxArray*>(prhs[2]));

    int n = f.length;
    int zSize[] = {1, n+1};
    Matrixf z(2, zSize);
    
    z[0] = -DBL_MAX;
    z[1] = DBL_MAX;
    
    int vSize[] = {1, n};
    Matrixf v(2, vSize);
    v[0] = 0;
    
    for(int q=1, k=0; q<n; q++)
    {
        double s = (invd*(pow(v[k]+mu, 2)-pow(q+mu, 2))+f[v[k]]-f[q])/(2*invd*(v[k]-q));
        while(s <= z[k]){
            k = k-1;
            s = (invd*(pow(v[k]+mu,2)-pow(q+mu,2))+f[v[k]]-f[q])/(2*invd*(v[k]-q));
        }        
        k = k+1;
        v[k] = q;
        z[k] = s;
        z[k+1] = DBL_MAX;
    }
    
    int DSize[] = {1, n};
    Matrixf D(2, DSize);
    
    int indSize[] = {1, n};
    Matrixf ind(2, indSize);
    
    for(int q=0, k=0; q<n; q++)
    {
        while(z[k+1]<q){
            k = k+1;
        }
        
        ind[q] = v[k] + 1;
        D[q] = invd * pow(q - v[k] - mu, 2) + f[v[k]];
    }
        
    plhs[0] = D.arr;
    plhs[1] = ind.arr;
}
