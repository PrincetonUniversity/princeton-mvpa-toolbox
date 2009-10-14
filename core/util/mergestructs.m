function [merged] = mergestructs(s1, s2, prefix)
% Merges two structures together.
%
% [MERGED] = MERGESTRUCTS(S1, S2)
%
% Merges the fields of two structures, S1 and S2. Conflicts are
% resolved by overwriting any S2 field with the S1 field.
%
% [MERGED] = MERGESTRUCTS(S1, S2, PREFIX)
%
% This usage prepends the string PREFIX to each of S1's fields before
% merging. This will usually avoid overwriting any of S2's fields, and
% can be used to rapidly generate large conglomerate structures.
%

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

merged = s2;

s1names = fieldnames(s1);

% combine structures, overwriting fields
for i = 1:numel(s1names)
  if nargin==3
    % Add a prefix to S1's fields
    merged.([prefix s1names{i}]) = s1.(s1names{i});
  else
    merged.(s1names{i}) = s1.(s1names{i});
  end
  
end

  

