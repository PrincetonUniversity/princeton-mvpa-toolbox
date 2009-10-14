function o = create_main_effect_contrast(nconds)

% Given N regressors, and assuming that each regressor
% represents a level of a single factor, this scripts creates
% a contrast matrix that will test for differences between
% each regressor and any of the other N regressor.
%
% In essence, it will turn a standard one-of-N regressors
% matrix used by STATMAP_ANOVA into a set of contrast
% regressors to be used by STATMAP_3DDECONVOLVE.
%
% If you were to run STATMAP_ANOVA on the one-of-N
% regressors and STATMAP_3dDECONVOLVE on these contrast
% regressors, you should get numerically identical
% results. However, this function gives you the added
% ability to include (1) non boolean regressor values;
% and (2) regressors of no interest.
%
% It is designed to be called by STATMAP_3DDECONVOLVE.M,
% so you probably won't actually need to call this directly.
%
% O (for 'output') is the new contrast matrix that will be
% multiplied by your regressors matrix to create orthogonal
% contrast regressors.

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


if nconds > 3
  
  h1_nconds = floor(nconds / 2);
  h2_nconds = ceil( nconds / 2);
  
  h1_tmp = create_main_effect_contrast(h1_nconds);
  h2_tmp = create_main_effect_contrast(h2_nconds);

  [m1 n1] = size(h1_tmp);
  [m2 n2] = size(h2_tmp);
  
  o = zeros(m1 + m2, n1 + n2);
  
  o(   1:m1 ,   1:n1 ) = h1_tmp;
  o(m1+1:end,n1+1:end) = h2_tmp;
  
  if n1 == n2
    hdr = cat(2, ones(1,n1), -1 * ones(1,n2));
  else
    hdr = cat(2, ones(1,n1) * -n2, ones(1,n2) * n1);
  end
  
  o = cat(1, hdr, o);
  
elseif nconds == 1
  % error('Can''t run a contrast with only one regressor - set ARGS.CONTRAST_MAT to 1.');
  o = 1;
elseif nconds == 2
  o = [1 -1];
elseif nconds == 3
  o = [2 -1 -1; 0 1 -1];
end
