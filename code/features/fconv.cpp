#include <mex.h>
#include <math.h>
#include <string.h>

// convolve A and B
void *convolve(double *A, double *B, double *C, 
        int outHeight, int outWidth, int filterHeight, int filterWidth, int filterDims, int srcHeight, int srcWidth) 
{   
    for (int f = 0; f < filterDims; ++f) {
        double *dst = C;
        double *A_src = A + f*srcHeight*srcWidth;
        double *B_src = B + f*filterHeight*filterWidth;
        for (int x = 0; x < outWidth; ++x) {
            for (int y = 0; y < outHeight; ++y) {
                double val = 0;
                for (int xp = 0; xp < filterWidth; ++xp) {
                    double *A_off = A_src + (x+xp)*srcHeight + y;
                    double *B_off = B_src + xp*filterHeight;
                    switch(filterHeight) {
                        case 20: val += A_off[19] * B_off[19];
                        case 19: val += A_off[18] * B_off[18];
                        case 18: val += A_off[17] * B_off[17];
                        case 17: val += A_off[16] * B_off[16];
                        case 16: val += A_off[15] * B_off[15];
                        case 15: val += A_off[14] * B_off[14];
                        case 14: val += A_off[13] * B_off[13];
                        case 13: val += A_off[12] * B_off[12];
                        case 12: val += A_off[11] * B_off[11];
                        case 11: val += A_off[10] * B_off[10];
                        case 10: val += A_off[9] * B_off[9];
                        case 9: val += A_off[8] * B_off[8];
                        case 8: val += A_off[7] * B_off[7];
                        case 7: val += A_off[6] * B_off[6];
                        case 6: val += A_off[5] * B_off[5];
                        case 5: val += A_off[4] * B_off[4];
                        case 4: val += A_off[3] * B_off[3];
                        case 3: val += A_off[2] * B_off[2];
                        case 2: val += A_off[1] * B_off[1];
                        case 1: val += A_off[0] * B_off[0];
                        break;
                        default:
                            for (int yp = 0; yp < filterHeight; ++yp) {
                                val += *(A_off++) * *(B_off++);
                            }
                    }
                }
                *(dst++) += val;
            }
        }
    }

    return 0;
}

// C = fconv(A, B);
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    if (nlhs != 1 || nrhs != 2){
        mexErrMsgTxt("Usage: C = fconv(A, B)");
    }
    
    // get A
    const mxArray *mxA = prhs[0];
    const mwSize *A_dims = mxGetDimensions(mxA);
    if (mxGetNumberOfDimensions(mxA)<2 || mxGetNumberOfDimensions(mxA)>3 || 
            mxGetClassID(mxA) != mxDOUBLE_CLASS)
        mexErrMsgTxt("Invalid input: A");
    double *A = (double *)mxGetPr(mxA);
    
    // get B
    const mxArray *mxB = prhs[1];
    const mwSize *B_dims = mxGetDimensions(mxB);
    if (mxGetNumberOfDimensions(mxB) < mxGetNumberOfDimensions(mxA) || 
            mxGetNumberOfDimensions(mxB) > 4 ||
            mxGetClassID(mxA) != mxDOUBLE_CLASS)
        mexErrMsgTxt("Invalid input: B");
    double *B = (double *)mxGetPr(mxB);
    
    int srcHeight = A_dims[0];
    int srcWidth = A_dims[1];
    int srcDims = mxGetNumberOfDimensions(mxA)>2 ? (int)A_dims[2] : 1;
    
    int filterHeight = B_dims[0];
    int filterWidth = B_dims[1];
    int filterDims = mxGetNumberOfDimensions(mxB)>2 ? (int)B_dims[2] : 1;   
    int filterNum = mxGetNumberOfDimensions(mxB) > 3 ? (int)B_dims[3] : 1;
    
    if(srcDims != filterDims){
        mexErrMsgTxt("Feature dimension mismatch.");
    }
    
    // prepare output
    int outHeight = srcHeight - filterHeight + 1;
    int outWidth = srcWidth - filterWidth + 1;
    if (outHeight < 1 || outWidth < 1)
        mexErrMsgTxt("Invalid input: B should be smaller than A");
    mwSize C_dims[] = {outHeight, outWidth, filterNum};
    mxArray* mxC = mxCreateNumericArray(3, C_dims, mxDOUBLE_CLASS, mxREAL);
    double *C = (double*)mxGetPr(mxC);
    plhs[0] = mxC;
    
    // do convolutions
    #pragma omp parallel for
    for (int i = 0; i < filterNum; ++i) 
    {
        convolve(A, 
                &B[i*filterHeight*filterWidth*filterDims], 
                &C[i*outHeight*outWidth], 
                outHeight, outWidth,
                filterHeight, filterWidth, filterDims,
                srcHeight, srcWidth);
    }
}
