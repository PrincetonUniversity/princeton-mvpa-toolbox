function [ia ib vol] = get_relative_index(subj, patname, maskname)

% Returns an index into a mask of the voxels in a pattern xxx
%
% [IDX] = GET_RELATIVE_INDEX(SUBJ, PATNAME, MASKNAME)
%
% Returns an index of the items in the pattern PATNAME as masked by
% the mask MASKNAME.  This is necessary to apply any mask, stored
% in 3D space, to a pattern, stored as a Voxels x TRs matrix.
%
% Note: If the mask includes voxels that are not present in the
% pattern, these voxels are excluded from the relative index.
%
% Optional Form: [IA IB VOL] = GET_RELATIVE_INDEX( ... )
% IA is the relative index of masked voxels in the pattern.  IB is
% the relative index of pattern voxels in the mask.  VOL is a 3D
% volume of the overlap.

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


patmask = get_objfield(subj,'pattern',patname,'masked_by');

patvol = get_mat(subj,'mask',patmask);
mskvol = get_mat(subj,'mask',maskname);

% Error checking
if any(size(patvol) ~= size(mskvol))
  error('Mask and Volume must reference a volume of same dimensions');
end

iPatvol = find(patvol);
iMskvol = find(mskvol);

[idx, ia, ib] = intersect(iPatvol, iMskvol);

vol = zeros(size(patvol));
vol(idx) = 1;
