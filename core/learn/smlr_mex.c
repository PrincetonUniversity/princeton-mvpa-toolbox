/*
 smlr_mex.c:

 This file contains the MEX optimized version of the Sparse
 Multinomial Logistic Regression algorithm described in:

 Krishnapuram, B., Figueiredo, M., Carin, L., & Hartemink, A. (2005)
   “Sparse Multinomial Logistic Regression: Fast Algorithms and
   Generalization Bounds.” IEEE Transactions on Pattern Analysis and
   Machine Intelligence (PAMI), 27, June 2005. pp. 957–968.

 This function should only be called by SMLR.m, as it relies on
 several precomputations that are done in Matlab.

 If this is not already compiled, compile with the following command:

 mex smlr_mex.c -lm CFLAGS='-fPIC -O3 -DNDEBUG -std=c99'   

 License:
 ======================================================================

 This is part of the Princeton MVPA toolbox, released under the
 GPL. See http://www.csbmb.princeton.edu/mvpa for more
 information.
 
 The Princeton MVPA toolbox is available free and
 unsupported to those who might find it useful. We do not
 take any responsibility whatsoever for any problems that
 you have related to the use of the MVPA toolbox.

 ======================================================================
*/

#include "mex.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <float.h>

/* ********************************************************************** */
// Calculates the softmax function.

static inline double softmax(double a, double delta) {

  double val = fabs(a) - delta;
  double sign = a > 0 ? 1 : -1;

  return val > 0 ? sign*val : 0;

}

/* ********************************************************************** */
// Runs SMLR iterative optimization.

int stepwise_regression(int N, int D, int M, 
			double w[M][D], float w_resamp[M][D],
			double X[D][N],
			double Xw[M][N], double E[M][N],
			double S[N],
			const double XY[M][D],
			const double B[D],
			const double delta[D],
			double maxiter,
			double tol,
			double decay_rate, 
			double decay_min, 
			int seed, 
			int verbose) {

  srand (seed);
  if (verbose) { // Output parameters in verbose mode
    printf("SMLR: random seed=%d\n", seed);
    printf("SMLR: decay: r=%g, min=%g\n", decay_rate, decay_min);
    printf("SMLR: tol=%g, maxiter=%g\n", tol, maxiter);
  }

  // initialize the iterative optimization
  int iter;
  double incr = DBL_MAX;

  // Begin iterative optimization
  for (iter = 0; iter < maxiter; iter++) {

    // Reset performance indicators for this iteration
    int wasted = 0;
    int saved = 0;
    int nonzero = 0;

    // zero out the sums for assessing convergence
    double sum2_w_diff = 0;
    double sum2_w_old = 0;

    // update each weight
    for (int d = 0; d < D; d++) {
      for (int m = 0; m < M; m++) {

	// get the starting weight
	double w_old = w[m][d];

	// Sample randomly to determine update probability
	double r = ((double)rand())/((double)RAND_MAX);
	
	// Update a given weight if non-zero or within sampling dist
	if ( w_old != 0 || r < w_resamp[m][d]) {

	  // Update predictions:
	  double XdotP = 0.0;
	  for (int i = 0; i < N; i++)
	    XdotP += X[d][i] * E[m][i]/S[i];

	  // get the gradient
	  double grad = XY[m][d] - XdotP;

	  // Calcluate the new weight 
	  double w_new = softmax(w_old + grad/B[d], delta[d]);
	  
	  // Debugging:
	  //printf("[%d,%d] - w_old: %g, XY: %g, XdotP: %g, grad: %g, w_new: %g\n", 
	  //d, m, w_old, XY[m][d], XdotP, grad, w_new);
	  
	  // Update our efficiency measures + resampling probabilities
	  if (w_new == 0  && w_old == 0) {
	    wasted++;
	    w_resamp[m][d] = (w_resamp[m][d]-decay_min)*decay_rate + decay_min;
	  }

	  if (w_new != 0 && w_old == 0)  {
	    saved++;
	    w_resamp[m][d] = 1;
	  }

	  double w_diff = w_new - w_old;

	  // If we changed, update our running calculations
	  if (w_diff != 0) {

	    for (int i = 0; i < N; i++)
	    {
	      Xw[m][i] += X[d][i]*w_diff;
	      double E_new_m = exp(Xw[m][i]);
	      S[i] += E_new_m - E[m][i];
	      E[m][i] = E_new_m;
	    }

	    // update the weight
	    w[m][d] = w_new;

	    // keep track of the sqrt sum squared distances
	    sum2_w_diff += w_diff*w_diff;
	  } 

	  if (w_new != 0)
	    nonzero++;

	  // might not have changed, but could be non-zero weight, so add to sum
	  sum2_w_old += w_old*w_old;
	}	
      }
    }

    // finished a iter, assess convergence
    incr = sqrt(sum2_w_diff) / (sqrt(sum2_w_old)+DBL_EPSILON);

    if (verbose)
      printf("SMLR [%d]: incr=%g (saved %d, wasted %d, nonzero %d)\n", 
	     iter, incr, saved, wasted, nonzero);

    // Check for convergence
    if (incr < tol)
      break;
  }

  return iter;
}

/* ********************************************************************** */
/* ********************************************************************** */
/*                             MEX CODE SECTION                           */
/* ********************************************************************** */
/* ********************************************************************** */

mxArray *copyMxArray(const mxArray *src) {
  
  mxArray *dest = mxCreateDoubleMatrix(mxGetM(src), mxGetN(src), mxREAL);
  
  double *dataSrc = mxGetPr(src);
  double *dataDest = mxGetPr(dest);

  // Copy the data, hopefully
  memcpy(dataDest, dataSrc, mxGetM(src)*mxGetN(src)*sizeof(*dataSrc));  

  return dest;
}

mxArray *copyMxArrayFloat(const mxArray *src) {
  
  mxArray *dest = mxCreateNumericMatrix(mxGetM(src), mxGetN(src), 
					mxSINGLE_CLASS, 0);
  float *dataSrc = mxGetData(src);
  float *dataDest = mxGetData(dest);

  // Copy the data, hopefully
  memcpy(dataDest, dataSrc, mxGetM(src)*mxGetN(src)*sizeof(*dataSrc));  

  return dest;
}

/* ********************************************************************** */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  /* Check for invalid usage */
  if (nrhs < 15) 
    mexErrMsgTxt("Not enough input arguments.");
  if (nrhs > 15)
    mexErrMsgTxt("Too many input arguments.");
  if (nlhs < 5)
    mexErrMsgTxt("Not enough output arguments.");
  if (nlhs > 5)
    mexErrMsgTxt("Too many output arguments.");

  /* --------------------------------------------------------------------- */
  /* Grab all the input arguments */

  const mxArray *w_in = prhs[0];  
  const mxArray *X = prhs[1];
  const mxArray *XY = prhs[2];
  const mxArray *Xw_in = prhs[3];
  const mxArray *E_in = prhs[4];
  const mxArray *S_in = prhs[5];
  const mxArray *B = prhs[6];
  const mxArray *delta = prhs[7];
  const mxArray *w_resamp_in = prhs[8];

  double maxiter = *mxGetPr(prhs[9]);
  double tol = *mxGetPr(prhs[10]);
  double decay_rate = *mxGetPr(prhs[11]);
  double decay_min = *mxGetPr(prhs[12]);
  int seed = (int)*mxGetPr(prhs[13]);
  int verbose = (int)*mxGetPr(prhs[14]);

  /* --------------------------------------------------------------------- */
  // Allocate extra memory to return modified copies of several inputs

  mxArray *w = copyMxArray(w_in);
  mxArray *Xw = copyMxArray(Xw_in);
  mxArray *E = copyMxArray(E_in); 
  mxArray *S = copyMxArray(S_in); 
  mxArray *w_resamp = copyMxArrayFloat(w_resamp_in); 

  /* --------------------------------------------------------------------- */
  // Run the SMLR iterative optimization loop
  int N = mxGetM(X);
  int D = mxGetN(X);
  int M = mxGetN(w);

  int iter = stepwise_regression(N, D, M,
				 mxGetData(w), mxGetData(w_resamp),
				 mxGetData(X), mxGetData(Xw), mxGetData(E),
				 mxGetData(S), 
				 mxGetData(XY), mxGetData(B), mxGetData(delta),
				 maxiter, tol, decay_rate, decay_min, 
				 seed, verbose);

  // Return the modified inputs
  plhs[0] = w;
  plhs[1] = Xw;
  plhs[2] = E;
  plhs[3] = S;  
  plhs[4] = mxCreateDoubleScalar(iter); //
}

