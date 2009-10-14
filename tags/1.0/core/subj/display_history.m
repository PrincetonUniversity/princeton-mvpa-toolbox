function [] = display_history(subj,objtype,objname)

% Display the object's history field in a friendly way
%
% [] = DISPLAY_HISTORY(SUBJ,OBJTYPE,OBJNAME)
%
% You can use this to display the SUBJ's own history if OBJTYPE ==
% 'subj' and OBJNAME == ''

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


obj = get_object(subj,objtype,objname);

nHists = length(obj.history);
for i=1:nHists
  disp( sprintf('%s',char(obj.history{i})) );
end
