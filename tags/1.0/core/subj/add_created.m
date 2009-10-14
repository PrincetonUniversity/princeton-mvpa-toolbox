function [subj] = add_created(subj,objtype,objname,new_creat)

% Makes it easier to add the object-creation data easier
%
% [SUBJ] = ADD_CREATED(SUBJ,OBJTYPE,OBJNAME,NEW_CREAT)
%
% Basically, you can feed it an entire NEW_CREAT structure, and
% it will add any fields that didn't already exist, overwrite any
% that did, but leave intact those that were already there.

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


if nargin < 4
  error('I think you missed out an argument');
end

if ~isstruct(new_creat)
  error('Your new created field has to be a struct');
end

old_creat = get_objfield(subj,objtype,objname,'created');
both_creat = mergestructs(new_creat,old_creat);

subj = set_objfield(subj,objtype,objname,'created',both_creat,'ignore_created',true);
