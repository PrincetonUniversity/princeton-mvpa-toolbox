function [mat] = get_group_as_matrix(subj,objtype,name,varargin)

% [MAT] = GET_GROUP_AS_MATRIX(SUBJ,OBJTYPE,NAME,...)
%
% Returns all the members of a group as a single matrix,
% with each member of the group getting its own row in the
% first dimension. In other words, the MAT it returns will
% be of the following sizes, depending on OBJTYPE:
%
% PATTERN (nMembers x nVox x nTimepoints)
%
% REGRESSORS (nMembers x nConds x nTimepoints)
%
% SELECTOR (nMembers x 1 x nTimepoints)
% 
% MASK (nMembers x X x Y x Z)
%
% If there is no such group as NAME, but there is a single
% object, it will return that (with nMembers = 1).
%
% Using this function if the members of the group are of
% different sizes isn't recommended. It should still work
% though, by zero-padding smaller group-members. See
% IGNORE_DIFF_SIZES.
%
% IGNORE_DIFF_SIZES (optional, default = false). By default,
% will issue a warning if any of the group-members' matrices
% are a different size from the first member's. Set this to
% true to turn off the warning.

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


defaults.ignore_diff_sizes = false;
args = propval(varargin,defaults);

members = find_group_single(subj,objtype,name);
nMembers = length(members);

first_matsize = get_objfield(subj,objtype,members{1},'matsize');
first_name = members{1};

% preinitialize the matrix
mat = zeros([nMembers first_matsize]);

for m=1:nMembers
  cur_name = members{m};
  
  cur_matsize = get_objfield(subj,objtype,cur_name,'matsize');
  if ~isequal(first_matsize, cur_matsize) & ~args.ignore_diff_sizes
    warning('%s is a different size from %s', cur_matsize, first_matsize);
  end
  
  cur_mat = get_mat(subj,objtype,cur_name);
  
  mat(m,:) = cur_mat(:);
    
end % m nMembers

