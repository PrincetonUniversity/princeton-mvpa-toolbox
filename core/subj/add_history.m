function [subj] = add_history(subj,objtype,objname,hist_str,displayme)

% Adds HIST_STR to OBJNAME's history field.
%
% [SUBJ] = ADD_HISTORY(SUBJ,OBJTYPE,OBJNAME,HIST_STR,[DISPLAYME])
%
% DISPLAYME (optional, default = false). If true, the HIST_STR gets
% echoed to the screen as well.
%
% If OBJTYPE = 'subj', then will append to the SUBJ header.history

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


if ~exist('displayme','var')
  displayme = false;
end

if displayme
  disp(hist_str);
end
hist_str = sprintf('%s: %s',datetime(),hist_str);

% Deal with OBJTYPE == 'subj' as a special case
if strcmp(objtype,'subj')
  subj = add_subj_history(subj,hist_str);
  return
end

obj = get_object(subj,objtype,objname);

if ~isfield(obj,'header')
  obj.header.history = [];
end
if ~isfield(obj.header,'history')
  obj.header.history=[];
end
  
obj.header.history{end+1}=hist_str;

subj = set_object(subj,objtype,objname,obj);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [subj] = add_subj_history(subj,hist_str)

% [SUBJ] = ADD_SUBJ_HISTORY(SUBJ,HIST_STR)
%
% Appends the hist_str to the subj.header


if ~isfield(subj,'header')
  subj.header.history=[];
end
if ~isfield(subj.header,'history')
  subj.header.history=[];
end

subj.header.history{end+1}=hist_str;
