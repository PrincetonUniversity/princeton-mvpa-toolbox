function [z] = zscore_mvpa(x,dim)

% This is a simple replacement for the Matlab Stats toolbox zscore
% function. It differs ever so slightly, because it takes in an
% optional DIM argument that determines which dimension it should
% operate along (like MAX, MIN, SUM, MEAN etc.).
%
% Note: if you're looking for an MVPA function to zscore your
% patterns as part of the subj structure, see ZSCORE_RUNS.M - this
% is just a simple auxiliary function to stand in for ZSCORE.M
%
% DIM (optional, default = 1 for matrices or column vectors, 2 for row
% vectors). These defaults are ever so slightly different than
% those of the Stats toolbox ZSCORE.M - here, the default dim is 1
% for matrices (2D max), whereas the Stats toolbox can deal with ND
% matrices and will use the lowest dimension with more than 1 value
% in it
%
% Note: this has been tested, but perhaps not as carefully as it
% should be

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


if ~isnumeric(x)
  error('Can''t zscore non-numeric data');
end

if isempty(x)
  z = [];
  return
end

% If you don't get fed a dim:
%   if it's a row vector, dim = 2. if it's a column vector, dim = 1
%   else, it must be a matrix, so default to 1
if ~exist('dim','var')
  dim = 1;
  if isrow(x)==1
    dim = 2;
  end
end

switch(dim)
 case 1
  z = do_z(x);
 case 2
  z = do_z(x')';
 otherwise
  error('Can only manage up to 2D matrices');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [z] = do_z(x)

nVals = size(x,1);
warn = warning('off','MATLAB:divideByZero');
xbar = repmat(mean(x),[nVals 1]);
sd = repmat(std(x),[nVals 1]);
warning(warn)
sd(sd==0) = 1;
z = (x - xbar) ./ sd;
