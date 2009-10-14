function [dt] = datetime()

% [dt] = datetime()
% spits out the date and time in yymmdd_HHMM format

dt = datestr(now,'yymmdd_HHMM');
