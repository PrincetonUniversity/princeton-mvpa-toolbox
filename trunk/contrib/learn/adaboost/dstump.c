/*
 * =============================================================
 * [FEAT THRESH CONF] = DSTUMP(WEIGHT,POS,NEG,SORTEDIX,EPSILON,TRAINPATS,SEED);
 *
 * Computes the feat, thresh, and conf for a weak hypotheses for a dataset on one AdaBoost round
 *
 * This is part of the Princeton MVPA toolbox, released under the
 * GPL. See http://www.csbmb.princeton.edu/mvpa for more
 * information.
 * Author: Melissa K. Carroll
 *
 * weight: size numclasses * numexamples
 * pos: size numclasses * numexamples
 * neg: size numclasses * numexamples
 * sortedix: size numexamples * numfeatures
 * trainpats: size numexamples * numfeatures
 *
 * Note that pos and neg are both required due to "don't care" conditions (which are neither pos nor neg)
 *
 * See Schapire and Singer (1999) for more details on Confidence-Rated AdaBoost
 * =============================================================
 
 % License:
%=====================================================================
%
% This is part of the Princeton MVPA toolbox, released under
% the GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% 
% The Princeton MVPA toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the MVPA toolbox.
%
% ======================================================================
 
 
 */

#include "mex.h"
#include "math.h"
#include "stdlib.h"

/*----------------------------*/
void dstump(double *weight, mxLogical *pos, mxLogical *neg, long *orderind, double *trainpats,
    int numfeat, int numex, int numclass, double *epsilon, long *feat, double *thresh, double *conf, unsigned int *seed)  {
    
    double *belowpos, *belowneg, *totalpos, *totalneg, abovepos, aboveneg, z, min, output;
    long i, r;
    int j, k, tie, weightoffset, indoffset, minorderind, threshindbelow, threshindabove;

    belowpos = mxCalloc(numclass,sizeof(double));   /*cumulative weight of pos examples below current thresh for each class*/
    belowneg = mxCalloc(numclass,sizeof(double));   /*cumulative weight of neg examples below current thresh for each class*/
    totalpos = mxCalloc(numclass,sizeof(double));   /*total weight of pos examples for each class*/
    totalneg = mxCalloc(numclass,sizeof(double));   /*total weight of neg examples for each class*/
   
    /*ties between "goodness" scores feature/thresholds are broken by selecting one at random with equal probability, 
    hence a randomization function is needed*/
    srand(*seed);
    tie = 1;
    
    /*initialize totalpos for each class*/
    for (k = 0; k < numclass; k++) {
        totalpos[k] = 0;
        totalneg[k] = 0;
    }
    
    /*determine the totalpos and totalneg weights*/
    for (j = 0; j < numex; j++) {                       /*for each example (column) in weight*/
        weightoffset = numclass * j;                    /*determine the offset*/
        for (k = 0; k < numclass; k++) {                /*for each class*/
            if (pos[weightoffset + k])                  /*add weight to totalpos if example is pos*/ 
                totalpos[k] += weight[weightoffset + k];
            else if (neg[weightoffset + k])             /*otherwise add weight to totalneg*/
                totalneg[k] += weight[weightoffset + k];
            }
    }
    
    /*determine the minimum z value (goodness score) over all feature/threshold combinations*/
    min = HUGE_VAL;
    
    for (i = 0; i < numfeat; i++) {                     /*for each feature (column)*/
        indoffset = numex * i;                          /*determine the offset into orderind and trainpats*/         
        for (k = 0; k < numclass; k++) {                /*initialize the cumulative weight records for each class*/
            belowpos[k] = 0;
            belowneg[k] = 0;
        }    
        /*initialize output to the minimum value to that feature
        orderind[indoffset] is the index (in trainpats) of the min example for that feature, since orderind lists the examples
        for each feature in ascending order
        trainpats offset by indoffset + that index is the value of that minimum example*/
        output = trainpats[indoffset + orderind[indoffset] - 1];    
        
        /*test every unique value of output to find the best splitting criterion*/
        for (j = 0; j < numex; j++) {                               /*for every example*/
            weightoffset = numclass * (orderind[indoffset + j] - 1);/*calculate the offset into pos, neg, and weight*/
                                                                    /*based on the trainpats index of the next highest
                                                                    value*/
            /*update the weight accumulation for the appropriate array for each class */           
            for (k = 0; k < numclass; k++) {                        
                if (pos[weightoffset + k])                          
                    belowpos[k] += weight[weightoffset + k];
                else if (neg[weightoffset + k])
                    belowneg[k] += weight[weightoffset + k];
            }    
            /*calculate the split if the last example is reached (to force a calculation) or a new value for that
            feature is encountered*/
            if (j == (numex - 1) || output != trainpats[indoffset + orderind[indoffset + j + 1] - 1]) {
                /*update current output tracker if its value has changed*/
                if (j != (numex - 1))
                    output = trainpats[indoffset + orderind[indoffset + j + 1] - 1];  
                /*calculate the z value as 2*(sum_j sum_blocks(sqrt(W_block_plus * W_block_minus))
                (see Schapire and Singer, 1999, eq. 16)*/
                z = 0;
                for (k = 0; k < numclass; k++) {
                    abovepos = totalpos[k] - belowpos[k];
                    aboveneg = totalneg[k] - belowneg[k]; 
                    z += sqrt(belowpos[k] * belowneg[k]) + sqrt(abovepos *  aboveneg);
                }
                z *= 2;
                /*test if this z value is a minimum
                if it is, increment the count of the number of ties for the min and generate
                the random tie-breaker number*/
                if (z == min) {
                    r = rand();
                    tie++;
                }      
                /*update min if this z is the new min or is selected at random among the ties
                also, if so, update the pointer to the feature (feat) and threshold (minorderind)
                associated with the weak learner*/
                if (z < min || ((z == min) && (r < RAND_MAX/tie))) {
                    min = z;
                    *feat = i + 1;
                    minorderind = j;                     
                }
            }              
        }
    }  
    /*compute the confidence scores for the minimum feature/threshold combination  
    find the offset for that feature*/
    indoffset = numex * (*feat - 1);
    /*initialize the weight accumulators*/
    for (k = 0; k < numclass; k++) {   
        belowpos[k] = 0;
        belowneg[k] = 0;
    }   
    /*accumulate the positive and negative weights over each example in sorted order until
    the chosen threshold is reached*/
    for (j = 0; j <= minorderind; j++) {
        weightoffset = numclass * (orderind[indoffset + j] - 1);           
        for (k = 0; k < numclass; k++) {     
            if(pos[weightoffset + k])
                belowpos[k] += weight[weightoffset + k];
            else if (neg[weightoffset + k])
                belowneg[k] += weight[weightoffset + k];
        }
    }
    /*calculate the above-threshold and below-threshold confidence scores for each class using eq.
    9 and variant in section 4.2 in Schapire and Singer, 1999.*/
    for (k = 0; k < numclass; k++) {
        conf[k] = log((belowpos[k] + *epsilon) / (belowneg[k] + *epsilon))/2;
        conf[numclass + k] = log((totalpos[k] - belowpos[k] + *epsilon) / (totalneg[k] - belowneg[k] + *epsilon))/2;    
    }   
    
    /*clear memory*/
    mxFree(belowpos);
    mxFree(belowneg);  
    mxFree(totalpos);
    mxFree(totalneg); 
    
    /*the actual threshold value will be the mean of the chosen threshold and the value of the next highest example for that feature
    obtain the appropriate indices*/
    threshindbelow = orderind[indoffset + minorderind] - 1;
    if (minorderind == numex - 1)
        threshindabove = orderind[indoffset + minorderind] - 1;
    else
        threshindabove = orderind[indoffset + minorderind + 1] - 1;
    /*determine the actual values in trainpats and take their mean*/
    *thresh = (trainpats[indoffset + threshindbelow] + trainpats[indoffset + threshindabove])/2;
}

/*mexFunction handles the argument processing*/
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    
double *weight, *epsilon, *trainpats;
long *orderind;
mxLogical *pos, *neg;
unsigned int *seed;
int *scalardims;
int numfeat, numex, numclass;
long *feat;
double *thresh, *conf;
  
 /*check that the appropriate number of arguments have been passed*/
  if (nrhs != 7) 
    mexErrMsgTxt("Weight, pos, neg, sortedix, epsilon, trainpats, seed required.");
  if (nlhs != 3) 
    mexErrMsgTxt("Outputs: feat, threshind, conf");
  
 /*validate the type of pos and neg (they will need to become mxLogical)*/
  if (!mxIsLogical(prhs[1]))
      mexErrMsgTxt("pos is not logical.");
  if (!mxIsLogical(prhs[2]))
      mexErrMsgTxt("neg is not logical.");

  /*collect the arguments*/
  weight = mxGetData(prhs[0]); 
  pos = mxGetLogicals(prhs[1]); 
  neg = mxGetLogicals(prhs[2]);   
  orderind = (long*)mxGetData(prhs[3]);    
  epsilon = mxGetData(prhs[4]);  
  trainpats = mxGetData(prhs[5]);   
  seed = mxGetData(prhs[6]);

  /*determine the dataset dimenions using the weight and sortedix matrices
  (see matrix sizes above - matrix dimensions are M x N)*/
  numclass = mxGetM(prhs[0]);
  numex = mxGetN(prhs[0]);
  numfeat = mxGetN(prhs[3]);

  /*create the output arguments*/
  
  /*feat is an index and will be returned as a 32-bit int
  set up the matrix size for feat*/
  scalardims = mxCalloc(2,sizeof(int));
  scalardims[0] = scalardims[1] = 1;
  plhs[0] = mxCreateNumericArray(2,scalardims,mxINT32_CLASS,mxREAL);
  /*create the thresh and conf output arguments*/
  plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
  plhs[2] = mxCreateDoubleMatrix(numclass,2,mxREAL);
  
  mxFree(scalardims);
  
  feat = (long *)mxGetPr(plhs[0]);
  thresh = (double *)mxGetPr(plhs[1]); 
  conf = mxGetPr(plhs[2]);  
  
  /*place the call the calculation function*/
  dstump(weight, pos, neg, orderind, trainpats, numfeat, numex, numclass, epsilon, feat, thresh, conf, seed);
}
    
