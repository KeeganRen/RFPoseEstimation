#include <math.h>
#include <algorithm>
#include <mex.h>
#include <vector>

#ifdef _WIN32
double log2( double n ){
    return log( n ) / log( 2.0 );
}
#endif

double* nodes = nullptr;
mwSize nodesDims[2];
double* leaves = nullptr;
mwSize leavesDims[2];
double* hists = nullptr;
#ifdef USE_DOUBLE
double* features = nullptr;
double* labels = nullptr;
#else
char* features = nullptr;
short* labels = nullptr;
#endif
mwSize* featuresDims = nullptr;
mwSize* labelsDims = nullptr;
double* descriptors = nullptr;
mwSize* descriptorsDims = nullptr;
int depth = 0;
int nPoints = 0;
int featureLength = 0;
int nClasses = 0;
int nThresholdBins = 0;
double minimumGain = 0;
int minimumSamples = 0;
//int currentNode = 0;
int nNodeFeatures = 0;
#ifdef USE_DOUBLE
double thresholdMargin = 0;
#else
int thresholdMargin = 0;
#endif

template<class T>
T& valueAt(T* ptr, const mwSize* size, long long i, long long j){
    return ptr[i+j*size[0]];
}

template<class T>
T& valueAt(T* ptr, const mwSize* size, long long i, long long j, long long k){
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

void fill_leaf(int nodeIndex, std::vector<long long>& indices)
{
    //printf("Reached leaf node.\n");
    //mexEvalString("drawnow");

    int leafIndex = nodeIndex - nodesDims[0];
    double norm = 1.0/(double)indices.size();
    std::vector<double> n(nClasses,0);
    for(long long i=0; i<indices.size(); ++i){
        int c = (int)labels[indices[i]];
        valueAt(leaves, leavesDims, leafIndex, c) += norm;
        valueAt(hists, leavesDims, leafIndex, c)++;
    }
}

int skip_to_leaf(int nodeIndex)
{
    valueAt(nodes, nodesDims, nodeIndex, 0) = 0;
    valueAt(nodes, nodesDims, nodeIndex, 1) = 0;
    valueAt(nodes, nodesDims, nodeIndex, 2) = -1;
    valueAt(nodes, nodesDims, nodeIndex, 3) = 0;
    
    int childIndex = nodeIndex;
    while(childIndex < nodesDims[0]){
        childIndex = (childIndex << 1) + 1;
    }
    return childIndex;
}

void split_node(int nodeIndex, std::vector<long long>& indices)
{
    // set terminal nodes
    if(nodeIndex >= nodesDims[0])
    {
        fill_leaf(nodeIndex, indices);
        return;
    }
    
    // If the minimum samples requirement is not satisfied, jump to left leaf
    if(indices.size() < minimumSamples)
    {       
        fill_leaf(skip_to_leaf(nodeIndex), indices);
        return;
    }
    
    //++currentNode;
    //printf("Splitting %7d/%d...", currentNode, nodesDims[0]);
    //mexEvalString("drawnow");
        
    double selGain = -DBL_MAX;
    int selFeature = 0;
#ifdef USE_DOUBLE
    double selThreshold = 0;
#else
    char selThreshold = 0;
#endif
    
    // Select a subset of features for evaluation on the current node
    std::vector<int> featureIndex(nNodeFeatures);
    if(nNodeFeatures<featureLength){
        for(int d=0; d<nNodeFeatures; ++d){
            featureIndex[d] = rand()%featureLength;
        }
    }
    else{
        for(int d=0; d<nNodeFeatures; ++d){
            featureIndex[d] = d;
        }
    }

    #pragma omp parallel for
    for(int d=0; d<nNodeFeatures; ++d)
    {
        double selGain_d = -DBL_MAX;
        int selFeature_d = 0;    
#ifdef USE_DOUBLE
        double selThreshold_d = 0;
        double* features_d = &valueAt(features, featuresDims, 0, featureIndex[d]);
        double minFV = +DBL_MAX;
        double maxFV = -DBL_MAX;
#else
        char selThreshold_d = 0;
        char* features_d = &valueAt(features, featuresDims, 0, featureIndex[d]);
        int minFV = SCHAR_MAX;
        int maxFV = SCHAR_MIN;
#endif       
                
        for(long long i=0; i<indices.size(); ++i)
        {
            auto fv = features_d[indices[i]];
            if(fv < minFV)
                minFV = fv;
            else if(fv > maxFV)
                maxFV = fv;
        }
        

#ifdef USE_DOUBLE
		std::vector<double> thresholds(nThresholdBins);
#else
		std::vector<char> thresholds(nThresholdBins);
#endif		
        
        for(int b = 0; b<nThresholdBins; ++b)
        {
#ifdef USE_DOUBLE
            thresholds[b] = (double)(b+1)*(maxFV-minFV)/(double)(nThresholdBins+1) + minFV;
#else
            thresholds[b] = (char)((b+1)*(maxFV-minFV)/(nThresholdBins+1) + minFV);
#endif
		}
            
        // Calculate the ratio of examples from each class that satisfy the threshold
        std::vector<double> nL(nThresholdBins*nClasses,0);
        std::vector<double> nR(nThresholdBins*nClasses,0);
        std::vector<int> nTotalL(nThresholdBins, 0);
        std::vector<int> nTotalR(nThresholdBins, 0);
        
        for(long long i=0; i<indices.size(); ++i)
        {
            auto fv = features_d[indices[i]];
            int c = (int)labels[indices[i]];
            for(int b = 0; b<nThresholdBins; ++b){
                if(fv > thresholds[b]){
                    ++nR[c*nThresholdBins+b];
                    ++nTotalR[b];
                }
                else{
                    ++nL[c*nThresholdBins+b];
                    ++nTotalL[b];
                }
            }
        }
        
        // Calculate enthropy
        for(int b = 0; b<nThresholdBins; ++b){
            double impurityL = 0;
            double impurityR = 0;
            double impurityAll = 0;
            for(int c = 0; c < nClasses; ++c){
                double ratioR = nR[c*nThresholdBins+b] / nTotalR[b];
                if(ratioR > 0)
                    impurityR -= ratioR * log2(ratioR);

                double ratioL = nL[c*nThresholdBins+b] / nTotalL[b];
                if(ratioL > 0)
                    impurityL -= ratioL * log2(ratioL);

                double ratioAll = (nR[c*nThresholdBins+b] + nL[c*nThresholdBins+b]) / (nTotalR[b] + nTotalL[b]);
                if(ratioAll > 0)
                    impurityAll -= ratioAll * log2(ratioAll);
            }

            double gain = impurityAll
                    - ((double)nTotalL[b]/(nTotalR[b] + nTotalL[b])) *  impurityL
                    - ((double)nTotalR[b]/(nTotalR[b] + nTotalL[b])) *  impurityR;

            if(gain > selGain_d){
                selGain_d = gain;
                selFeature_d = featureIndex[d];
                selThreshold_d = thresholds[b];
            }
        }
        
        #pragma omp critical
        {
            if(selGain_d > selGain){
                selGain = selGain_d;
                selFeature = selFeature_d;
                selThreshold = selThreshold_d;
            }
        }
    }
    
    //printf("done.\n");
    //mexEvalString("drawnow");
    
    // If the minimum gain requirement is not satisfied, jump to left leaf
    if(selGain < minimumGain)
    {        
        fill_leaf(skip_to_leaf(nodeIndex), indices);
        return;
    }
    
    //printf("Maximum information gain: %f, feature: %d\n", selGain, selFeature);
    
    // Set feature descriptor to current node
    valueAt(nodes, nodesDims, nodeIndex, 0) =
            valueAt(descriptors, descriptorsDims, selFeature, 0);
    valueAt(nodes, nodesDims, nodeIndex, 1) =
            valueAt(descriptors, descriptorsDims, selFeature, 1);
    valueAt(nodes, nodesDims, nodeIndex, 2) =
            valueAt(descriptors, descriptorsDims, selFeature, 2);
    valueAt(nodes, nodesDims, nodeIndex, 3) = (double)selThreshold;
    
    
    // Recursively run the same function for child nodes
    std::vector<long long> indicesL;
    std::vector<long long> indicesR;
    
#ifdef USE_DOUBLE
    double* features_d = &valueAt(features, featuresDims, 0, selFeature);
    double thresholdR = selThreshold - thresholdMargin;
    double thresholdL = selThreshold + thresholdMargin;
#else
    char* features_d = &valueAt(features, featuresDims, 0, selFeature);
    char thresholdR = (char)std::max(selThreshold - thresholdMargin, SCHAR_MIN);
    char thresholdL = (char)std::min(selThreshold + thresholdMargin, SCHAR_MAX);
#endif
        
    for(long long i=0; i<indices.size(); ++i)
    {
        auto fv = features_d[indices[i]];
        if(fv > thresholdR){
            indicesR.push_back(indices[i]);
        }
        if(fv <= thresholdL){
            indicesL.push_back(indices[i]);
        }
    }    
   
    split_node((nodeIndex<<1)+1, indicesL);
    split_node((nodeIndex<<1)+2, indicesR);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if(nlhs!=1 || nrhs!=4){
        mexErrMsgTxt("Usage: tree = forest_learn(features, labels, descriptors, params)\n");
    }
    
    printf("Learning decision forest.\n");
    
    const mxArray* featuresArr = prhs[0]; // nPoints x featureLength
    const mxArray* labelsArr = prhs[1]; // nPoints x 1
    const mxArray* descriptorsArr = prhs[2];
    const mxArray* paramsArr = prhs[3];
        
#ifdef USE_DOUBLE
    if(mxGetClassID(featuresArr)!=mxDOUBLE_CLASS){
        mexErrMsgTxt("Invalid feature type, expecting double array.\n");
    }
    features = (double*)mxGetData(featuresArr);
#else
    if(mxGetClassID(featuresArr)!=mxINT8_CLASS){
        mexErrMsgTxt("Invalid feature type, expecting int8 array.\n");
    }
    features = (char*)mxGetData(featuresArr);
#endif
    featuresDims = (mwSize*)mxGetDimensions(featuresArr);

#ifdef USE_DOUBLE
    if(mxGetClassID(labelsArr)!=mxDOUBLE_CLASS){
        mexErrMsgTxt("Invalid label type, expecting double array.\n");
    }
    labels = (double*)mxGetData(labelsArr);
#else
    if(mxGetClassID(labelsArr)!=mxINT16_CLASS){
        mexErrMsgTxt("Invalid label type, expecting int16 array.\n");
    }
    labels = (short*)mxGetData(labelsArr);
#endif
    labelsDims = (mwSize*)mxGetDimensions(labelsArr);
    
    descriptors = mxGetPr(descriptorsArr);
    descriptorsDims = (mwSize*)mxGetDimensions(descriptorsArr);
    
    depth = (int)mxGetScalar(safeGetField(paramsArr, 0, "depth"));
    nPoints = featuresDims[0];
    featureLength = descriptorsDims[0];
    nClasses = (int)mxGetScalar(safeGetField(paramsArr, 0, "nClasses"));
    nThresholdBins = (int)mxGetScalar(safeGetField(paramsArr, 0, "nThresholdBins"));
    minimumGain = (double)mxGetScalar(safeGetField(paramsArr, 0, "minimumGain"));
    minimumSamples = (int)mxGetScalar(safeGetField(paramsArr, 0, "minimumSamples"));
    nNodeFeatures = (int)mxGetScalar(safeGetField(paramsArr, 0, "nNodeFeatures"));
#ifdef USE_DOUBLE
    thresholdMargin = (double)mxGetScalar(safeGetField(paramsArr, 0, "thresholdMargin"));
#else
    thresholdMargin = (int)mxGetScalar(safeGetField(paramsArr, 0, "thresholdMargin"));
#endif
    
    if(nNodeFeatures > featureLength){
        mexErrMsgTxt("Number of features per node should be less or equal to the total number of features.\n");
    }
    
    printf("Building a tree with depth: %d\n", depth);
    printf("Data points: %d\n", nPoints);
    printf("Number of classes: %d\n", nClasses);
    printf("Threshold bins: %d\n", nThresholdBins);
    printf("Minimum gain: %f\n", minimumGain);
    printf("Minimum node samples: %d\n", minimumSamples);
    printf("Number of features per node: %d\n", nNodeFeatures);
    mexEvalString("drawnow");
    
    mwSize treesDims[] = {1};
    const char* treesFields[] = {"nodes", "leaves", "hists"};
    mxArray* treesArr = mxCreateStructArray(1, treesDims, 3, treesFields);
    
    // create an array of all point indices
    std::vector<long long> indices(nPoints);
    for(int i=0; i<nPoints; ++i){
        indices[i] = i;
    }
    
    // allocate nodes and add them to the tree
    nodesDims[0] = (1 << (depth-1)) - 1;
    nodesDims[1] = 4;
    mxArray* nodesArr = mxCreateNumericArray(2, nodesDims, mxDOUBLE_CLASS, mxREAL);
    nodes = mxGetPr(nodesArr);
    
    leavesDims[0] = (1 << (depth-1));
    leavesDims[1] = nClasses;
    mxArray* leavesArr = mxCreateNumericArray(2, leavesDims, mxDOUBLE_CLASS, mxREAL);
    leaves = mxGetPr(leavesArr);
    
    mxArray* histsArr = mxCreateNumericArray(2, leavesDims, mxDOUBLE_CLASS, mxREAL);
    hists = mxGetPr(histsArr);
    
    mxSetField(treesArr, 0, "nodes", nodesArr);
    mxSetField(treesArr, 0, "leaves", leavesArr);
    mxSetField(treesArr, 0, "hists", histsArr);
    
    // split nodes
    //currentNode = 0;
    split_node(0, indices);
    
    // print number of used nodes
    int usedLeaves = 0;
    for(int i=0; i<leavesDims[0]; ++i){
        bool used = false;
        for(int j=0; j<leavesDims[1]; ++j){
            if(valueAt(leaves, leavesDims, i, j) != 0.0){
                used = true;
                break;
            }
        }
        if(used){
            ++usedLeaves;
        }
    }
    printf("Effective nodes: %d/%d\n", usedLeaves*2-1, (1<<depth)-1);
    
    printf("Process completed.\n");
    
    plhs[0] = treesArr;
}

