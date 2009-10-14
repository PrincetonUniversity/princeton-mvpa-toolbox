function [errmsgs warnmsgs] = alert_unit_errors(errmsgs,warnmsgs)

% Alerts if there are errors in a unit test
%
% [ERRMSGS WARNMSGS] = ALERT_UNIT_ERRORS(ERRMSGS,WARNMSGS)
%
% Ideally, you'd run all your unit tests en masse as part of
% a suite, but if you have an individual unit test function
% that you want to run, just call this at the end and it
% will briefly summarize any errors.


% alert the user if there are any erro rmessages
if length(errmsgs)
  dispf('Ohoh. %i errmsgs\n----',length(errmsgs));
  
  for e=1:length(errmsgs)
    disp(errmsgs{e})
  end % e

else
  disp('Woohoo. No errmsgs')
end
