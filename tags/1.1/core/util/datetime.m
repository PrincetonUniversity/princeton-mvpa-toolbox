function [dt] = datetime(seconds)

% Spits out the date and time in yymmdd_HHMM format
%
% [dt] = datetime([seconds])
%
% The advantage of this is that alphabetic order is also
% chronological).
%
% If SECONDS = true, adds _SS at the end (defaults to false).
%
% UPDATE: it looks like there's a bug in DATESTR, so we're making 2 separate calls and concatenating them to work around it (see below).


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


if ~exist('seconds','var')
  seconds = false;
end

% get the current time as an unintelligible integer
n = now();

% deal with the DATESTR bug by concatenating 2 separate calls,
% otherwise it gives the wrong output if you feed in 'yymmdd_HHMM' as
% a format string.
%
%   http://www.mathworks.com/matlabcentral/newsreader/view_thread/236006
if seconds
  dt = [datestr(n,'yymmdd') '_' datestr(n,'HHMM_SS')];
else
  dt = [datestr(n,'yymmdd') '_' datestr(n,'HHMM')];
end



