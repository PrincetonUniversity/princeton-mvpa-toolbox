function [] = pause5(txt,dur)

% Pauses for 5 seconds
%
% [] = pause5(txt,dur)
%
% Use this if you want to do an action by default, but
% want to give the user the chance to press Ctrl-C
%
% TXT (default = ''). Display this text as a warning of
% what's about to happen
%
% DUR (default = 5000). # milliseconds to pause before
% continuing. Won't let you specify a value below 5000,
% in case this is accidentally set to 5


if ~exist('txt')
  txt = '';
end

if ~exist('dur')
  dur = 5000;
end

if dur<5000
  dur = 5000;
end
dur_s = dur / 1000;

dbstack

if ~isempty(txt)
  disp(txt)
end

disp( sprintf('Continuing in %i secs unless you press Ctrl-C',dur_s) );
pause(dur_s)

