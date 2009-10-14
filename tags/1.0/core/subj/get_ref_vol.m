function [vol] = get_ref_vol(subj,patname)

% Returns the mat of the pattern's masked_by mask
%
% [VOL] = GET_REF_VOL(SUBJ,PATNAME)
%
% Think of this as getting the pattern's 'reference volume'.
%
% Every pattern needs to know which mask it's masked by, because the
% pattern throws away information about where its voxels/features come
% from. If you want to know which voxel is which, then you need to be
% able to refer back to a 3D volume reference space. That's what the
% masked_by field in all the patterns is for. This is a quick way of
% getting the reference space for a given pattern

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


masked_by = get_objfield(subj,'pattern',patname,'masked_by');

if isempty(masked_by)
  error('Every pattern should know which mask it''s masked by, but this one doesn''t');
end

vol = get_mat(subj,'mask',masked_by);
