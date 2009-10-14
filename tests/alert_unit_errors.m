function [errs warns] = alert_unit_errors(errs,warns)

% Alerts if there are errors in a unit test
%
% [ERRS WARNS] = ALERT_UNIT_ERRORS(ERRS,WARNS)
%
% Ideally, you'd run all your unit tests en masse as part of
% a suite, but if you have an individual unit test function
% that you want to run, just call this at the end and it
% will briefly summarize any errors.


% alert the user if there are any error messages
if length(errs)
  dispf('Ohoh. %i errs\n----',length(errs));
  
  for e=1:length(errs)
    disp(errs{e})
  end % e

else
  disp('Woohoo. No errs')
end
