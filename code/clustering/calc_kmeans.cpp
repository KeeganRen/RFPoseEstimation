//
//  calc_kmeans.cpp
//
//  Created by Vahid Kazemi
//  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
//

#include <math.h>
#include <algorithm>
#include <mex.h>
#include <memory.h>
#include <vector>
#include <random>
#include <functional>
#include "tools.h"

struct KMeansParams
{
    int nPoints;
    int nDims;
    int nClusters;
    int nIterations;
    double threshold;
};

void kmeans(const double* data, KMeansParams params, int* outInds, double* outCenters)
{
    std::random_device randomDevice;

    // start with random cluster centers
#pragma omp parallel
    {
	auto seed = 0;
#pragma omp critical 
	seed = randomDevice(); 

	std::mt19937 randomGenerator(seed);
        auto uniformInt = std::bind(std::uniform_int_distribution<>(0, params.nPoints-1), randomGenerator);
        
#pragma omp for
        for(int k=0; k<params.nClusters; ++k){
            int i = uniformInt();
            vecCopy(&outCenters[k*params.nDims], &data[i*params.nDims], params.nDims);
        }
    }
    
    std::vector<int> clusterSizes(params.nClusters);
    std::vector<bool> assignmentChange(params.nPoints);
    
    for(int it=0; it<params.nIterations; ++it)
    {        
        // assign data points to cluster centers
        #pragma omp parallel for
        for(int i=0; i<params.nPoints; ++i)
        {
            const double* curPoint = &data[(int64)i*(int64)params.nDims];

            // find the cluster with minimum distance to current point
            double selDistance = DBL_MAX;
            int selClusterID = 0;
            for(int k=0; k<params.nClusters; ++k){
                double* curCenter = &outCenters[k*params.nDims];
                double curDistance = vecDistance(curPoint, curCenter, params.nDims);
                if(curDistance < selDistance){
                    selDistance = curDistance;
                    selClusterID = k;
                }
            }
            
            assignmentChange[i] = (outInds[i] != selClusterID);
            outInds[i] = selClusterID;
        }
               
        // sum up points which belong to same cluster
        int totalChange = 0;
        std::fill(clusterSizes.begin(), clusterSizes.end(), 0);
        std::fill(outCenters, outCenters+(params.nClusters*params.nDims), 0);
        for(int i=0; i<params.nPoints; ++i)
        {
            int k = outInds[i];
            vecAdd(&outCenters[k*params.nDims], &data[(int64)i*(int64)params.nDims], params.nDims);            
            ++clusterSizes[k];
            if(assignmentChange[i]){
                ++totalChange;
            }
        }     
        
        // normalize center points, create singleton clusters
#pragma omp parallel
        {
     	    auto seed = 0;
#pragma omp critical 
            seed = randomDevice();
	
            std::mt19937 randomGenerator(seed);
            auto uniformInt = std::bind(std::uniform_int_distribution<>(0, params.nPoints-1), randomGenerator);
            
            #pragma omp for
            for(int k=0; k<params.nClusters; ++k)
            {
                double* curCenter = &outCenters[k*params.nDims];
                if(clusterSizes[k]==0){
                    int i = uniformInt();
                    outInds[i] = k;
                    vecCopy(curCenter, &data[i*params.nDims], params.nDims);
                }
                else{
                    double inv = 1.0 / (double)clusterSizes[k];
                    vecMul(curCenter, inv, params.nDims);
                }
            }   
        }
        
        if((double)totalChange/(double)params.nPoints < params.threshold){
            break;
        }
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    // get data from matlab
    if(!(nlhs==2 && nrhs>=2)){
        mexErrMsgTxt("Usage: inds = calc_kmeans(X, k).");
    }
    
    const mxArray* dataArr = prhs[0];
    const mxArray* nClustersArr = prhs[1];
    
    if(mxGetClassID(dataArr)!=mxDOUBLE_CLASS){
        mexErrMsgTxt("Invalid feature type, expecting double array.");
    }

    double* data = (double*)mxGetData(dataArr);
    mwSize* dataDims = (mwSize*)mxGetDimensions(dataArr);    
        
    KMeansParams params;
    params.nDims = dataDims[0];
    params.nPoints = dataDims[1];
    params.nClusters = (int)mxGetScalar(nClustersArr);
    params.nIterations = 100;
    params.threshold = 0.01;
    
    if(nrhs > 2){
        const mxArray* structArr = prhs[2];
        safeGetScalarField(structArr, 0, "nIterations", params.nIterations);
        safeGetScalarField(structArr, 0, "threshold", params.threshold);
    }
    
    if(params.nClusters > params.nPoints){
        mexErrMsgTxt("Number of clusters should be less than number of points.");
    }
    
    mwSize indsDims[] = {1, params.nPoints};
    mxArray* indsArr = mxCreateNumericArray(2, indsDims, mxINT32_CLASS, mxREAL);
    int* inds = (int*)mxGetData(indsArr);
    
    mwSize centersDims[] = {params.nDims, params.nClusters};
    mxArray* centersArr = mxCreateNumericArray(2, centersDims, mxDOUBLE_CLASS, mxREAL);
    double* centers = (double*)mxGetData(centersArr);
    
    // kmeans algorithm
    kmeans(data, params, inds, centers);
    
    // convert to matlab 1 based format
    #pragma omp parallel for
	for(int i=0; i<params.nPoints; ++i){
        ++inds[i];
    }
       
    plhs[0] = indsArr;
    plhs[1] = centersArr;
    
    return;
}
