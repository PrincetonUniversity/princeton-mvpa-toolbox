function [isthere] = exist_group(subj,objtype,objname)

% Checks whether a group of that type and name exist
%
% [ISTHERE] = EXIST_GROUP(SUBJ,OBJTYPE,OBJNAME)
%
% Just calls find_group and checks whether it's empty

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


isthere = ~isempty(find_group(subj,objtype,objname));

