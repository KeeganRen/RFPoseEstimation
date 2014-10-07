//
//  Created by Vahid Kazemi
//  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
//

#include <math.h>
#include <algorithm>
#include <memory.h>
#include <mex.h>

template<class T>
void maxfilt(T* data, int stride, int size, int radius){
	for(int i=0; i<size; ++i){
		for(int j=std::max(0, i-radius); j<std::min(size, i+radius+1); ++j){
			if(data[j*stride] < data[i*stride]){
				data[j*stride] = data[i*stride];
			}
		}
	}
}

template<class T>
void nonmaxsup2(T* input, T* output, int d1, int d2, int radius){
	memcpy(output, input, d1*d2*sizeof(T));
	
	for(int i=0; i<d2; ++i){
		maxfilt(&output[i*d1], 1, d1, radius);
	}
	
	for(int i=0; i<d1; ++i){
		maxfilt(&output[i], d1, d2, radius);
	}
	
	int length = d1*d2;
	for(int i=0; i<length; ++i){
		if(input[i]!=output[i]){
			output[i] = 0;
		}
	}
}

template<class T>
void nonmaxsup3(T* input, T* output, int d1, int d2, int d3, int radius){
	memcpy(output, input, d1*d2*d3*sizeof(T));
	
	for(int i=0; i<d3; ++i){
		for(int j=0; j<d2; ++j){
			maxfilt(&output[i*d1*d2+j*d1], 1, d1, radius);
		}
	}
	
	for(int i=0; i<d3; ++i){
		for(int j=0; j<d1; ++j){
			maxfilt(&output[i*d1*d2+j], d1, d2, radius);
		}
	}
	
	for(int i=0; i<d2; ++i){
		for(int j=0; j<d1; ++j){
			maxfilt(&output[i*d1+j], d1*d2, d3, radius);
		}
	}
	
	int length = d1*d2*d3;
	for(int i=0; i<length; ++i){
		if(input[i]!=output[i]){
			output[i] = 0;
		}
	}
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if(nlhs!=1 || nrhs!=2){
        mexErrMsgTxt("Usage: output = nonmaxsup(input, radius)\n");
    }
    
	const mxArray* inputArr = prhs[0];            
	int nDims = mxGetNumberOfDimensions(inputArr);
	if (mxGetClassID(inputArr) != mxDOUBLE_CLASS || 
		!(nDims == 2 ||  nDims == 3)) {
		mexErrMsgTxt("Invalid input array type or dimension.");
	}	
	int radius = (int)mxGetScalar(prhs[1]);
	
	const mwSize* inputDims = mxGetDimensions(inputArr);
	double* input = mxGetPr(inputArr);
	
    mxArray* outputArr = mxCreateNumericArray(nDims, inputDims, mxDOUBLE_CLASS, mxREAL);
    double* output = mxGetPr(outputArr);
    
	if(nDims==2){
		nonmaxsup2(input, output, inputDims[0], inputDims[1], radius);
	}
	else{
		nonmaxsup3(input, output, inputDims[0], inputDims[1], inputDims[2], radius);
	}
		
    	
    plhs[0] = outputArr;
}
