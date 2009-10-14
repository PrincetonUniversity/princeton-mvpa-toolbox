function [isthere] = exist_group(subj,objtype,objname)

% Checks whether a group of that type and name exist
%
% [ISTHERE] = EXIST_GROUP(SUBJ,OBJTYPE,OBJNAME)
%
% Just calls find_group and checks whether it's empty


isthere = ~isempty(find_group(subj,objtype,objname));

