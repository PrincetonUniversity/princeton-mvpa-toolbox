function dims = spm_extract_voxel_dims(subj, objtype, objname)

% This function accesses the header.vol area of a pattern generated from
% the load_analyze_pattern function and returns the voxel dimensions of
% that object for use in other pieces of software or just for basic
% reference.
%
% [dims] = SPM_EXTRACT_VOXEL_DIMS(subj, objtype, objname)
%
%% Required Fields
%
% SUBJ(MVPA SUBJ): the subject object you wish to extract dimensions from.
%
% OBJTYPE(mask,pattern): the type of object you wish to extract dimensions
% from.
%
% OBJNAME(string): The name of the object inside the subject that you wish
% to extract dimension information from.
%
%% License:
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


% this program is actually pretty simple it access the header.vol of a
% given object and returns the first three values of the diagnol of the
% .mat object in the header.

%% Retrieve Header
% First retrieve the header of the object you wish to extract.
vol_header = get_objsubfield(subj,objtype,objname,'header','vol');
%% Confirm it's a cell object or convert to cell object
%then make sure the object is a cell object, if it is not things won't work
%the way they are supposed to 
if ~iscell(vol_header)
    temp = vol_header;
    vol_header = cell(1);
    vol_header{1} = temp;
    clear temp;
end
%% Extract the working mat area
% {1}(1) will be fine, the mat is uniform throughout the volume header
working_mat = vol_header{1}(1).mat;
% populate dims using the first three values of the diagonal of working_mat
dims(1) = working_mat(1,1);
dims(2) = working_mat(2,2);
dims(3) = working_mat(3,3);


end

