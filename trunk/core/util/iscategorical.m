function [t] = iscategorical(mat) 
% Returns true if the matrix is a categorical regressors matrix.
%
% [T] = ISCATEGORICAL(MAT)
%
% This function will eventually replace CHECK_1OFN_REGRESSORS in
% in a future MVPA release.

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

t = false;
 
% Check for single vector of integer categories
if size(mat, 1) == 1 && all(round(mat) == mat)
  t = true;
end

% check for binary, '1-of-n' categories:
if all(mat(:) == 0 | mat(:) == 1) && ...
      all(sum(mat) == 0 | sum(mat) == 1) % only one label active
                                         % per timepoint
  t = true;
end


  
  
