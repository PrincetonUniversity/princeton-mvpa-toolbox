function [starttime timeleft] = eta(cur,total,starttime, interval)
% Display an estimate of time remaining in a calculation.
%
% function [starttime timeleft] = eta(cur,total,starttime, interval)
%
% Usage:
%
% t0 = clock;
% t0 = eta(cur,total,t0,0.05);

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


if nargin<4
  interval=0;
end

if starttime == 0;
  starttime = clock;
end

% Get the elapsed time
elapsed = etime(clock, starttime);
avgtime = elapsed./cur;
timeleft = (total-cur)*avgtime;

if interval>0
  interval = ceil(total*interval);

%  dispf('cur: %g, total: %g, interval: %g, mod: %g', ...
%        cur, total, interval, mod(cur,interval));
  
  if cur == 1, fprintf('Progress:\n'); 
  elseif mod(cur,interval) == 0
    fprintf('\t%.f%% (%s remaining.)\n', (cur/total)*100, ...
            estimate(timeleft));
  end

end




