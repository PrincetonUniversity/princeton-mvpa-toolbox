function [subj] = set_group_as_matrix(subj,objtype,name,mat,varargin)

% [SUBJ] = SET_GROUP_AS_MATRIX(SUBJ,OBJTYPE,NAME,MAT, ...)
%
% Use DUPLICATE_GROUP, grab the GROUP_MAT, modify it, and then
% SET_GROUP_AS_MATRIX.
%
% xxx - i couldn't decide on an elegant way to deal with the 


members = find_group_single(subj,objtype,name);
nMembers = length(members);
assert(nMembers==size(mat,1));

for m=1:nMembers
  cur_name = members{m};
  
  switch objtype
   case 'pattern'
    cur_mat = mat(m,:,:);
    cur_mat = reshape(cur_mat,[size(mat,2) size(mat,3)]);
   case 'regressors'
    cur_mat = mat(m,:,:);
    cur_mat = reshape(cur_mat,[size(mat,2) size(mat,3)]);
   case 'selector'
    cur_mat = mat(m,1,:);
    cur_mat = reshape(cur_mat,[1 size(mat,3)]);
   case 'mask'
    cur_mat = mat(m,:,:,:);
    cur_mat = reshape(cur_mat,[size(mat,2) size(mat,3) size(mat,4)]);
   otherwise
    error('Unknown objtype');
  end
  
  cur_matsize = get_objfield(subj,objtype,cur_name,'matsize');
  % the matrix we're inserting should be the same size as the matrix
  % we're overwriting
  assert(isequal(cur_matsize,size(cur_mat)));
  
  subj = set_mat(subj,objtype,cur_name,cur_mat);

end % m nMembers



