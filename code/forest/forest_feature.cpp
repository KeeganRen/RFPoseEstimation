#include <math.h>
#include <algorithm>
#include <mex.h>
#include <vector>

template<class T>
T& valueAt(T* ptr, const mwSize* size, long i, long j){
    return ptr[i+j*size[0]];
}

template<class T>
T& valueAt(T* ptr, const mwSize* size, long i, long j, long k){
    return ptr[i+j*size[0]+k*size[0]*size[1]];
}

template<class T>
T clamp(T val, T minval, T maxval){
    if(val < minval)return minval;
    if(val > maxval)return maxval;
    return val;
}

const mxArray* safeGetField(const mxArray *structArr, mwIndex index, const char* fieldname){
    const mxArray* arr = mxGetField(structArr, index, fieldname);
    if(arr==nullptr){
        char errMsg[256];
        sprintf(errMsg, "Error: field %s not found.\n", fieldname);
        mexErrMsgTxt(errMsg);
    }
    return arr;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if(nlhs!=1 || nrhs!=4){
        mexErrMsgTxt("Usage: features = forest_feature(input, points, descriptors, params);\n");
    }
    
    const mxArray* inputArr = prhs[0];
    const mxArray* pointsArr = prhs[1];
    const mxArray* descriptorsArr = prhs[2];
    const mxArray* paramsArr = prhs[3];
       
#ifdef USE_DOUBLE
    if(mxGetClassID(inputArr)!=mxDOUBLE_CLASS){
        mexErrMsgTxt("Invalid input type, expecting double array.\n");
    }
    double* input = (double*)mxGetData(inputArr);
#else
    if(mxGetClassID(inputArr)!=mxINT8_CLASS){
        mexErrMsgTxt("Invalid input type, expecting int8 array.\n");
    }
    char* input = (char*)mxGetData(inputArr);
#endif
    const mwSize* inputDims = mxGetDimensions(inputArr);
    
    double* points = mxGetPr(pointsArr);
    const mwSize* pointsDims = mxGetDimensions(pointsArr);
        
    double* descriptors = mxGetPr(descriptorsArr);
    const mwSize* descriptorsDims = mxGetDimensions(descriptorsArr);
    
    int height = inputDims[0];
    int width = mxGetNumberOfDimensions(inputArr) > 1 ? inputDims[1] : 1;
    int nTypes = mxGetNumberOfDimensions(inputArr) > 2 ? inputDims[2] : 1;
    int nPoints = pointsDims[0];
    int featureLength = descriptorsDims[0];
        
    mwSize featuresDims[] = {nPoints, featureLength};
#ifdef USE_DOUBLE
    mxArray* featuresArr = mxCreateNumericArray(2, featuresDims, mxDOUBLE_CLASS, mxREAL);
    double* features = (double*)mxGetData(featuresArr);
#else
    mxArray* featuresArr = mxCreateNumericArray(2, featuresDims, mxINT8_CLASS, mxREAL);
    char* features = (char*)mxGetData(featuresArr);
#endif
    
    // for all the points
    #pragma omp parallel for
    for(int p=0; p<nPoints; ++p)
    {          
        // extract all descriptors
        for(int d=0; d<featureLength; ++d)
        {
            int x = (int)valueAt(points, pointsDims, p, 0);
            int y = (int)valueAt(points, pointsDims, p, 1);
            
            int offX  = (int)valueAt(descriptors, descriptorsDims, d, 0);
            int offY  = (int)valueAt(descriptors, descriptorsDims, d, 1);
            int type  = (int)valueAt(descriptors, descriptorsDims, d, 2);
            
            int absX = clamp(x + offX, 0, width-1);
            int absY = clamp(y + offY, 0, height-1);
            type = clamp(type, 0, nTypes-1);
            
            valueAt(features, featuresDims, p, d) =
                    valueAt(input, inputDims, absY, absX, type);
        }
    }
    
    plhs[0] = featuresArr;
}
