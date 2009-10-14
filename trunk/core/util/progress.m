function [made_progress] = progress(cur,total,nWaypoints)

% Display a text-based progress counter
%
% [MADE_PROGRESS] = PROGRESS(CUR,TOTAL,[NWAYPOINTS])
%
% Displays a progress counter that spits out an 'x%' marker
% every 100/nWaypoints of the way through a big loop. By default
% then, it will print out every 10%.
%
% nWaypoints (optional, default = 10). The number of increments
% towards completion to read out. Note: this is not a
% PROPVAL optional argument.
%
% See WAITBAR for a flashy progress bar that uses figures
% - less good if you're running over SSH.
%
% MADE_PROGRESS = boolean, true when we just made it past a
% waypoint.
%
% e.g.
%
%   for v=1:nVox
%     progress(v,nVox);
%     % do something
%   end % v

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

made_progress = false;

if cur==1
  % let the user know that a long process is starting
  fprintf('\t...')
  return
end

if ~exist('nWaypoints','var')
  nWaypoints = 10;
end

if cur==total
  fprintf('  %.f%%', 100); % prints 100%
  dispf('  done\n')
  made_progress = true;
  return
end

if mod(cur, floor(total/nWaypoints)) == 0
  fprintf('  %.f%%', (cur/total)*100); % prints e.g. 10%
  made_progress = true;
end
