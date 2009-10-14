function [isthere] = exist_object(subj,objtype,objname)

% Checks whether an object of that type + name exists
%
% [ISTHERE] = EXIST_OBJECT(SUBJ,OBJTYPE,OBJNAME)
%
% Just calls get_number with IGNORE_ABSENCE = true

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


isthere = get_number(subj,objtype,objname,'ignore_absence',true);

