function [actives] = and_bool_selectors(subj,selnames)

% Takes in multiple boolean selectors and ANDs them
%
% [ACTIVES] = AND_BOOL_SELECTORS(SUBJ,SELNAMES)
%
% Returns another boolean vector of the same size.
%
% If SELNAMES is just a string, treats it as a cell array
% of length 1

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


if isempty(selnames)
  error('You must feed in at least one selector name');
end

if ~iscell(selnames)
  selnames = {selnames};
end

actives = get_mat(subj,'selector',selnames{1});
check_binary(actives);

if length(selnames)==1
  return
end

for s=2:length(selnames)
  cursel = get_mat(subj,'selector',selnames{s});
  if size(cursel,2)~=size(actives,2)
    error('Your selectors aren''t all the same size');
  end
  check_binary(cursel);
  actives = actives & cursel;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = check_binary(sel)

% check that all the values are binary
if length(find(sel==0)) + length(find(sel==1)) ...
      ~= numel(sel)
  error('The selectors being ANDED together must be binary');
end

