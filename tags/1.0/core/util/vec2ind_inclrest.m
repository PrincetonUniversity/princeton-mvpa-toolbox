function [ind] = vec2ind_inclrest(vec)

% Like vec2ind, but deals differently with 0s
%
% [IND] = VEC2IND_INCLREST(VEC)
%
% See the builtin VEC2IND function for more information. This takes
% in a matrix, and tells you where the 1 is for every column.
%
% Useful for figuring out which condition is active in your binary regressors

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

[isbool isrest isoveractive] = check_1ofn_regressors(vec);

if ~isbool
  error('Vec needs to be boolean');
end

if isoveractive
  error('Can''t have more than one active item in each column');
end

[nrows ncols] = size(vec);

ind = zeros(1,ncols);
for i = 1:nrows
  ind(find(vec(i,:))) = i;
end


