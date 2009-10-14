function [errs warns] = unit_create_xvalid_oddeven(subj)

% Unit test for CREATE_XVALID_ODDEVEN.M.
%
% [ERRS WARNS] = UNIT_CREATE_XVALID_ODDEVEN(SUBJ)


errs = {};
warns = {};

[errs warns] = basic_case(errs,warns);
[errs warns] = uneven_nruns(errs,warns);

% alert the user if there are any problems
[errs warns] = alert_unit_errors(errs,warns);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errs warns] = basic_case(errs,warns)

[subj runs] = create_subj(6);

subj = create_xvalid_oddeven(subj,'runs');

runs_xvoe_1 = get_mat(subj,'selector','runs_xvoe_1');
runs_xvoe_2 = get_mat(subj,'selector','runs_xvoe_2');

desired_1 = runs*10;
% all the odd should be training
desired_1(desired_1==10) = 1;
desired_1(desired_1==30) = 1;
desired_1(desired_1==50) = 1;
% even for testing
desired_1(desired_1==20) = 2;
desired_1(desired_1==40) = 2;
desired_1(desired_1==60) = 2;
if ~isequal(desired_1, runs_xvoe_1)
  errs{end+1} = 'Basic case failed for xvoe 1';
end

% i'm multiplying the runs * 10, so that i don't
% accidentally set a bunch of runs to 1s, and then replace
% the ones with something else
desired_2 = runs*10;
% this time, all the even should be training
desired_2(desired_2==20) = 1;
desired_2(desired_2==40) = 1;
desired_2(desired_2==60) = 1;
% and all the odd should be testing
desired_2(desired_2==10) = 2;
desired_2(desired_2==30) = 2;
desired_2(desired_2==50) = 2;
if ~isequal(desired_2, runs_xvoe_2)
  errs{end+1} = 'Basic case failed for xvoe 2';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errs warns] = uneven_nruns(errs,warns)

% should test whether it still works for an odd number of
% runs
%
% xxx perhaps it should fail???

% subj = create_subj(7);

% try
%   subj = create_xvalid_oddeven(subj,'runs');
%   errs{end+1} = 'Should fail if nRuns isn''t even';
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [subj runs] = create_subj(nRuns);

nTRsPerRun = 5;
runs = [];
for r=1:nRuns
  runs = [runs ones(1,nTRsPerRun)*r];
end % r nRuns

subj = init_subj('unit_create_xvalid_oddeven','');
subj = initset_object(subj,'selector','runs',runs);

