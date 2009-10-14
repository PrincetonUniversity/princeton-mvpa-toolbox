function [subj betas X] = detrend_pattern(subj, patname, selname, varargin)
% DETREND_PATTERN - Remove trends from a given pattern over runs.
%
% Usage:
%
% [SUBJ BETAS X] = DETREND_PATTERN(SUBJ, PATNAME, RUNSNAME, ...)
%
% DETREND_PATTERN removes trends from the pattern PATNAME for each
% run specified in RUNSNAME. DETREND_PATTERN can remove linear,
% polynomial, and arbitrary trends.
%
% Linear and polynomial detrending is controlled by the optional
% POLORT propval; this functions exactly as the POLORT term to AFNI's
% 3dDetrend command, except that individual POLORT terms can be
% specified for each run by specifying POLORT to be an array. By
% default, linear detrending is applied to each run (POLORT =
% [1]). Values of POLORT greater than 1 include Legendre Polynomials
% of order N, ..., 1, so that POLORT = 3, for instance, would
% performance cubic, quadratic, and linear detrending. POLORT of 0
% removes baseline shifts only.
%
% To detrend arbitrary trends, a regressors matrix can be included
% as a regressor by specifying the optional propval INCLUDE. Note
% that the regressors will be included as a single regressor for
% all runs, so if you want per-run detrending, you will need to set
% up a regressors matrix with a separate regressor for each run.
%
% The beta weights for each voxel and each trend are returned in
% BETAS. The final design matrix used to detrend each voxel is
% returned in X.
%
% Optional Arguments:
%
%   'polort' - Polynomial detrending parameter or vector of
%              parameters (different POLORT for each run).
%              (Default: [1]).
%
%   'include' - What 'regressors' object from the SUBJ structure to
%               include in the design matrix. (Default: none).
%
%   'new_patname' - The name of the new detrended pattern.
%
% SEE ALSO
%   CREATE_LEGENDRE
  

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

defaults.polort = 1; % by default: linear detrending for each run
defaults.include = ''; % by default: don't include any additional regressors
defaults.new_patname = sprintf('%s_dt', patname);

args = propval(varargin,defaults);

% dependent variable: the voxel activities
Y = get_mat(subj, 'pattern', patname)';

runs = get_mat(subj, 'selector', selname);

dispf('Detrending pattern ''%s'' with polort=%s, include=%s', ...
       patname, mat2str(args.polort), args.include);

% Build up the design matrix
X = [];
for r = unique(runs)

  % These are the non-zero timepoints
  idx = find(runs==r);
  
  % Find the order of the polynomial we want
  if numel(args.polort) == 1
    polort = args.polort;
  else
    polort = args.polort(r);
  end
  
  % make the individual columns for this run
  n = numel(idx);
  x = zeros(numel(runs), 1+polort);
  
  % baseline + polynomial
  x(idx,:) = [ones(n,1) create_legendre(n,polort)'];
  
  X = horzcat(X,x);
end

% Optionally include another regressor to regress out
if ~isempty(args.include)  
  X = [X get_mat(subj,'regressors',args.include)'];
end

% Peform detrending
betas = zeros(cols(Y),cols(X));
  
warning off MATLAB:rankDeficientMatrix;
  
b = X \ Y;
yhat = X*b;

Y = Y - yhat;

betas = b;

warning on MATLAB:rankDeficientMatrix;

maskname = get_objfield(subj,'pattern',patname,'masked_by');

% Reinsert the old pattern
subj = initset_object(subj, 'pattern', args.new_patname, Y', ...
                      'masked_by', maskname);
dispf('pattern ''%s'' created by detrend_pattern', args.new_patname);



