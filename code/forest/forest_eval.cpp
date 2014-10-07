#include <math.h>
#include <algorithm>
#include <mex.h>
#include <vector>

#ifdef _WIN32
double log2( double n ){  
    return log( n ) / log( 2.0 );  
}
#endif

struct Tree
{
    double* nodes;
    double* leaves;
    const mwSize* nodesDims;
    const mwSize* leavesDims;
};

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
    if(!(nlhs==1 || nlhs==2) || nrhs!=2){
        mexErrMsgTxt("Usage: output = forest_eval(input, model)\n");
    }
    
	const mxArray* inputArr = prhs[0];
    const mxArray* modelArr = prhs[1];
    
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
    
    int height = inputDims[0];
    int width = mxGetNumberOfDimensions(inputArr) > 1 ? inputDims[1] : 1;
    int nTypes = mxGetNumberOfDimensions(inputArr) > 2 ? inputDims[2] : 1;
        
    const mxArray* treesArr = safeGetField(modelArr, 0, "trees");  
    int nTrees = (int)mxGetNumberOfElements(treesArr);    
    if(nTrees <= 0){
        mexErrMsgTxt("No trees to traverse!\n");
    }   
    //printf("Number of trees: %d\n", nTrees);   
    
    std::vector<Tree> trees;
    
    for(int t=0; t<nTrees; ++t)
    {
        const mxArray* nodesArr = safeGetField(treesArr, t, "nodes");
        double* nodes = mxGetPr(nodesArr);
        const mwSize* nodesDims = mxGetDimensions(nodesArr);
        
        const mxArray* leavesArr = safeGetField(treesArr, t, "leaves");
        const mwSize* leavesDims = mxGetDimensions(leavesArr);
        double* leaves = mxGetPr(leavesArr);
        
        //printf("Tree[%d] has %d non-terminal nodes, and %d leaves\n", 
        //        t, nodesDims[0], leavesDims[0]);
        
        int depth = log2(nodesDims[0]+leavesDims[0]+1);
        int nNodes = (1 << (depth-1)) - 1;
        int nLeaves = (1 << (depth-1));
                
        if(nodesDims[0]!=nNodes || leavesDims[0]!=nLeaves){
            char errorMsg[256];
            sprintf(errorMsg, "Invalid number of nodes. "
                    "The tree should have %d non-terminals, and %d leaves.\n", 
                    nNodes, nLeaves);
            mexErrMsgTxt(errorMsg);
        }
        
        if(nodesDims[1]!=4){
            mexErrMsgTxt("Wrong tree format!");
        }
        
        Tree tree = {nodes, leaves, nodesDims, leavesDims};
        trees.push_back(tree);
    }
    
    // normalizatin factor for each tree
    double invNTree = 1/(double)nTrees;
    
    // length of target variables
    int nClasses = trees[0].leavesDims[1];
    
    mwSize outputDims[] = {height, width, nClasses};
    mxArray* outputArr = mxCreateNumericArray(3, outputDims, mxDOUBLE_CLASS, mxREAL);
    double* output = mxGetPr(outputArr);
    
    mwSize indexDims[] = {height, width, nTrees};
    mxArray* indexArr = nullptr;
    double* index = nullptr;
    if(nlhs>1){
        indexArr = mxCreateNumericArray(3, indexDims, mxDOUBLE_CLASS, mxREAL);
        index = mxGetPr(indexArr);
    }
        
    // search over all the trees
    for(int t=0; t<nTrees; ++t)
    {
        // searh over all the pixels
        for(int x=0; x<width; ++x){
            for(int y=0; y<height; ++y){
                // traverse the binary tree
                int nodeIndex = 0;
                while(nodeIndex<trees[t].nodesDims[0])
                {                    
                    int offX = (int)valueAt(trees[t].nodes, trees[t].nodesDims, nodeIndex, 0);
                    int offY = (int)valueAt(trees[t].nodes, trees[t].nodesDims, nodeIndex, 1);
                    int type = (int)valueAt(trees[t].nodes, trees[t].nodesDims, nodeIndex, 2);
#ifdef USE_DOUBLE
                    double threshold = valueAt(trees[t].nodes, trees[t].nodesDims, nodeIndex, 3);
#else
                    char threshold = (char)valueAt(trees[t].nodes, trees[t].nodesDims, nodeIndex, 3);
#endif
                            
                    int absY = clamp(y + offY, 0, height-1);
                    int absX = clamp(x + offX, 0, width-1);
                    type = clamp(type, -1, nTypes-1);
                                           
                    if( type >= 0 )
                    {
                        if(valueAt(input, inputDims, absY, absX, type) > threshold)
                            nodeIndex = (nodeIndex<<1) + 2;
                        else
                            nodeIndex = (nodeIndex<<1) + 1;
                    }
                    else
                    {                      
                        while(nodeIndex<trees[t].nodesDims[0]){
                            nodeIndex = (nodeIndex<<1) + 1;
                        }
                    }
                }
                               
                // find the terminal node
                int leafIndex = nodeIndex - trees[t].nodesDims[0];                
                //printf("%d => %d\n", nodeIndex, leafIndex);
                for(int c=0; c<nClasses; ++c){
                    valueAt(output, outputDims, y, x, c) += invNTree *
                            valueAt(trees[t].leaves, trees[t].leavesDims, leafIndex, c);
                }
                
                if(nlhs>1){
                    valueAt(index, indexDims, y, x, t) = leafIndex;
                }
            }
        }
    }
	
    plhs[0] = outputArr;
    if(nlhs>1){
        plhs[1] = indexArr;
    }
}
