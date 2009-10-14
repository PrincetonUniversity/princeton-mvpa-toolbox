function [subj] = move_all_patterns_to_hd(subj)

% [SUBJ] = MOVE_ALL_PATTERNS_TO_HD(SUBJ)

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

fprintf('Moving all patterns to HD ...');

nPats = length(subj.patterns);
for p=1:nPats
  cur_patname = get_name(subj,'pattern',p);
  if ( ...
      ~exist_objfield(subj,'pattern',cur_patname,'movehd') && ...
      sum(get_objfield(subj,'pattern',cur_patname,'matsize')) ...
      )
    subj = move_pattern_to_hd(subj,cur_patname);
  end
end % p nPats

fprintf(' done\n')

