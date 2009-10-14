/*
Computes cross correlation between all rows in a matrix and a given
row vector.

Usage - [xcorr] = compute_xcorr(REGSMAT, PATMAT)

Where REGSMAT is a row vector from a regressors object and PATMAT is
the matrix from a pattern object.

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

/* get a Matlab (i,j) value from the matlab array */
double getMatrixValue(double* pMat, int cols, int i, int j) {
  return pMat[i*cols + j];
}

/* compute the mean of a row vector */
double mean(double *mat, int size) {

  double sum = 0;
  int i;

  for (i = 0; i < size; i++)
    sum += mat[i];

  return sum / size;
}

/* compute a sum of the form: (x - x_mean) * (y - y_mean) */
double computeVarSum(double *x, double x_mean, double *y, double
		      y_mean, int n) {

  int i;
  double out = 0;

  for (i = 0; i < n; i++)
    out += (x[i] - x_mean) * (y[i] - y_mean);

  return out;
}

/* compute the cross correlation */
void computeXCorr(double *out, double *regs, double *pat, int rows,
		   int cols) {

  int v;
  double mean_regs,  mean_row, regs_var, row_var;
  double *row_ptr;
  
  /* compute mean of regressor */
  mean_regs = mean(regs, cols);
  
  /* compute regs variance */
  regs_var = computeVarSum(regs, mean_regs, regs, mean_regs, cols);

  if (regs_var == 0) {
    printf("Error: regressor has variance 0\n");
    return;
  }
    
  for (v = 0; v < rows; v++) {

    /* get pointer to row */
    row_ptr = pat + (v*cols);

    /* get row mean */    
    mean_row = mean(row_ptr, cols);

   /* get row variance */
    row_var = computeVarSum(row_ptr, mean_row, row_ptr, mean_row, cols);

    if (row_var == 0) {
      printf("Error: row %d has variance 0\n", v);
      return;
    }

    /* compute cross correlation */
    out[v] = computeVarSum(regs, mean_regs, row_ptr, mean_row, cols) /
      sqrt(regs_var * row_var);

  }

  /* all done */
  return;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray
		 *prhs[]) {			
  
  mxArray *regsData, *patData;
  double *regsValues, *patValues, *outValues;
  int regsRows, regsCols, patRows, patCols; 

  /* Check for invalid arguments */
  if (nrhs != 2 || nlhs != 1) {
    return;    
  }

  /* get the pointers and data */
  regsData = prhs[0];
  patData = prhs[1];

  /* get the matrices and their sizes */
  regsValues = mxGetPr(regsData);
  regsRows = mxGetN(regsData);
  regsCols = mxGetM(regsData);

  patValues = mxGetPr(patData);
  patRows = mxGetN(patData);
  patCols = mxGetM(patData);

  /* check that matrices are the right sizes */
  if (patCols != regsCols || regsRows != 1) {
    printf("Error: invalid matrices passed as arguments: [%d, %d] vs  [%d, %d]\n", 
    patRows, patCols, regsRows, regsCols);
    return;
  }

  /* create the output matrix: 1 value for each foxel */  
  plhs[0] = mxCreateDoubleMatrix(patRows, 1, mxREAL);

  /* get the pointer to the output data */
  outValues = mxGetPr(plhs[0]);

  /* compute cross correlation  */
  computeXCorr(outValues, regsValues, patValues, patRows, patCols);
  
  return;
}

