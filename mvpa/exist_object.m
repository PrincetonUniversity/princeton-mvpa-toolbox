function [isthere] = exist_object(subj,objtype,objname)

% Checks whether an object of that type + name exists
%
% [ISTHERE] = EXIST_OBJECT(SUBJ,OBJTYPE,OBJNAME)
%
% Just calls get_number with IGNORE_ABSENCE = true


isthere = get_number(subj,objtype,objname,'ignore_absence',true);

