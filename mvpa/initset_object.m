function [subj] = initset(subj,objtype,objname,newmat,varargin)

% Calls init_object then set_mat (and set_objfield optionally)
%
% [SUBJ] = INITSET(SUBJ,OBJTYPE,OBJNAME,NEWMAT,...)
%
% This is for lazy people who want to init their object and then
% put the mat inside it, all in one go
%
% You can also set as many fields as you like at the same time. If
% they don't already exist, they will be created. Just add propval
% pairs as normal as a cell array in the varargin for fieldname +
% value, e.g.
%
% subj = initset(subj,'pattern','epi',mypat,'masked_by','wholebrain');
%
% Note: you won't get a warning if adding a field that doesn't
% already exist, so be careful to type your fieldnames
% correctly


args = propval(varargin,[], ...
	       'ignore_empty_defaults',true, ...
	       'ignore_missing_default',true);

subj = init_object(subj,objtype,objname);

subj = set_mat(subj,objtype,objname,newmat);

fields = fieldnames(args);

for f=1:length(fields)
  curfield = fields{f};
  curval = args.(curfield);
  subj = set_objfield(subj,objtype,objname,curfield,curval,'ignore_absence',true);
end % f
