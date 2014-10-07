//
//  Created by Vahid Kazemi
//  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
//

#pragma once

const double PI = 3.14159265358979323846;

typedef char        int8;
typedef short       int16;
typedef int         int32;
typedef long long   int64;

class Matrixf
{
public:
    explicit Matrixf(mxArray* arr) : 
        arr(arr),
        ptr(mxGetPr(arr)),
        ndim(mxGetNumberOfDimensions(arr)),
        length((int)mxGetNumberOfElements(arr)),
        size(mxGetDimensions(arr))
    {
        if(mxGetClassID(arr)!=mxDOUBLE_CLASS){
            mexErrMsgTxt("Input data needs to be in double format.\n");
        }
    }
    
    Matrixf(int ndim, const mwSize* size):
        arr(mxCreateNumericArray(ndim, size, mxDOUBLE_CLASS, mxREAL)),
        ptr(mxGetPr(arr)),
        ndim(ndim),
        length((mwSize)mxGetNumberOfElements(arr)),
        size(mxGetDimensions(arr)){
    }
            
    double& operator[](mwSize i){
        return ptr[i];
    }
    
    double& at(mwSize i){
        return ptr[i];
    }
    
    double& at(mwSize i, mwSize j){
        return ptr[i+j*size[0]];
    }
    
    double& at(mwSize i, mwSize j, mwSize k){
        return ptr[i+j*size[0]+k*size[0]*size[1]];
    }
    
    double& at(int *sub){
        int sz = 1;
        int ind = sub[0];
        for(int i=1; i<ndim; i++){
            sz *= size[i-1];
            ind += sz * sub[i];
        }
        return ptr[ind];
    }
    
    void destroy(){
        mxDestroyArray(arr);
    }
    
    mxArray* arr;   
    const mwSize ndim;
    const mwSize length;
    const mwSize *size;     
    double* ptr;
};

template<class T>
struct Vector2
{
    Vector2(){}
    Vector2(T x, T y) : x(x), y(y){}
    Vector2 operator+(const Vector2& v) const{
        return Vector2(v.x+x, v.y+y);
    }
    T x, y;
};

template<class T>
struct BBox 
{
    BBox(){}
    BBox(Vector2<T> c, Vector2<T> s): c(c), s(s){}   
    BBox(T cx, T cy, T sx, T sy): 
        c(cx,cy), s(sx,sy){}    
    Vector2<T> c;
    Vector2<T> s;
};

template<class T>
T clamp(T val, T minval, T maxval)
{
    if(val>maxval)return maxval;
    if(val<minval)return minval;
    return val;
}

template<class T>
void swap(T& a, T& b)
{
    T temp = a;
    a = b;
    b = temp;
}

template<class T>
T round(T val)
{
    return floor(val+0.5);
}

template<class T>
T square(T val){
    return val * val;
}

template<class T>
T vecDistance(const T* x, const T* y, int nDims){
    T dist = 0;
    for(int i=0; i<nDims; ++i){
        dist += square(x[i]-y[i]);
    }
    return dist;
}

template<class T>
void vecAdd(T* x, const T*y, int nDims){
    for(int i=0; i<nDims; ++i){
        x[i] += y[i];
    }
}

template<class T>
void vecMul(T* x, T value, int nDims){
    for(int i=0; i<nDims; ++i){
        x[i] *= value;
    }
}

template<class T>
void vecCopy(T* x, const T* y, int nDims){
    for(int i=0; i<nDims; ++i){
        x[i] = y[i];
    }
}

template<class T>
T& valueAt(T* ptr, const mwSize* size, long i, long j){
    return ptr[i+j*size[0]];
}

template<class T>
T& valueAt(T* ptr, const mwSize* size, long i, long j, long k){
    return ptr[i+j*size[0]+k*size[0]*size[1]];
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

template<class T>
void safeGetScalarField(const mxArray *structArr, mwIndex index, const char* fieldname, T& value){
    const mxArray* arr = mxGetField(structArr, index, fieldname);
    if(arr!=nullptr){
        value = (T)mxGetScalar(arr);
    }
}

#ifdef __cplusplus
extern "C" {
#endif
mxArray* mxTranspose(const mxArray *, int);
#ifdef __cplusplus
}
#endif


