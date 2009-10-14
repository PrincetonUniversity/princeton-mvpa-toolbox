function [errmsgs warnmsgs] = test_zscore_mvpa()

% USAGE : [ERRMSGS WARNMSGS] = TEST_ZSCORE_MVPA()
% Tests ZSCORE_MVPA against the Stats toolbox zscore
% 
% OUTPUT ARGUMENT: ERRMSGS
% The output argument, 'errmsgs' holds the error strings that the
% function gives out if it fails any of the tests.
%
% WARNMSGS = cell array, like ERRMSGS, of tests that didn't pass
% and didn't fail (e.g. because they weren't run)


%initialising the *msgs cell arrays
errmsgs = {}; 
warnmsgs = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a negative test.
% this test should fail if the function works with no arguments.
if ~iserror('subj = set_mat();')
  errmsgs{end+1} = 'No arguments test:failed'
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checks if you have the stat toolbox 
if isempty(which('zscore'))
  warnmsgs{end+1} = 'No Stats toolbox zscore to compare it to';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compares the output the zscore and the zscore_mvpa function using
% a 100 x 100 matrix 
matrix = rand(100);
if ~compare_versions(matrix)
  errmsgs{end+1} = 'Comparison Test failed for a matrix';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compares the output the zscore and the zscore_mvpa function using
% a 1 x 100 matrix 
vector = rand([100 1]);
if ~compare_versions(vector)
  errmsgs{end+1} = 'Comparison Test failed for a vector';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compares the output the zscore and the zscore_mvpa function using
% an empty matrix 
empty_mat = [];
if ~compare_versions(empty_mat)
  errmsgs{end+1} ='Comparison Test failed for an empty matrix';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compares the output of the zscore and the zscore_mvpa function using
% an allzeros vector.
% checks if the output with all zeros is what we expect it to be.
allzeros=zeros(1,10);
if ~compare_versions(allzeros)
  errmsgs{end+1} = 'Comparison Test failed for an allzeros pattern';
end 
desired_out = zeros(1,10);
if ~isequal(zscore(allzeros),desired_out)
  errmsgs{end+1} = 'Allzeros Test: This is not the desired output'
end
clear desired_out;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compares the output the zscore and the zscore_mvpa function using
% a  vector with all the same values.
% checks if the output with all same is what we expect it to be.
allsame=ones(1,10)*12;
if ~compare_versions(allsame)
  errmsgs{end+1} = 'Comparison Test failed for an allsame pattern';
end 
desired_out = zeros(1,10);
if ~isequal(zscore(allsame),desired_out)
  errmsgs{end+1} = 'Allsame Test: This is not the desired output'
end

clear desired_out;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compares the output the zscore and the zscore_mvpa function using
% a vector with a  single NaN value.
% checks if the output with one Nan is what we expect it to be.
singleNaN = rand(1,10);
singleNaN(1,5)= NaN;
if ~compare_nan(singleNaN)
  errmsgs{end+1} = 'Comparison Test failed for a single NaN pattern'
end 
desired_out = NaN(1,10);
if ~isequalwithequalnans(zscore(singleNaN),desired_out)
  errmsgs{end+1} = 'SingleNaN Test: This is not the desired output'
end
clear desired_out;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compares the output the zscore and the zscore_mvpa function using
% a multiple NaN vector
% check if the output with multiple Nan is what we expect it to be.
multiNaN = rand(1,10);
multiNaN(1,5)= NaN; multiNaN(1,9)= NaN; 
if ~compare_nan(multiNaN)
  errmsgs{end+1} = ' Comparison Test failed for a multiple NaN pattern'
end 
desired_out = NaN(1,10);
if ~isequalwithequalnans(zscore(multiNaN),desired_out)
  errmsgs{end+1} = 'MultipleNaN Test: This is not the desired output'
end
  
clear desired_out;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compares the output the zscore and the zscore_mvpa function using
% an all NaN vector 
% checks if the output with all NaNs is what we expect it to be.
allNaN = NaN(1,10);
if ~compare_nan(allNaN)
  errmsgs{end+1} = 'Comparison Test failed for an all NaN pattern'
end 
desired_out = NaN(1,10);
if ~isequalwithequalnans(zscore(allNaN),desired_out)
  errmsgs{end+1} = 'AllNaN Test: This is not the desired output'
end
clear desired_out;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compares the output the zscore and the zscore_mvpa function using
% a vector with an infiinity value 
% checks if the output with a single inf value is what we expect it to be.
singleinf = ones(1,10)*12;
singleinf(1,10) = inf;
if ~compare_nan(singleinf)
  errmsgs{end+1} = ' Comparison Test failed for a single_inf pattern'
end 
desired_out = NaN(1,10);
if  ~isequalwithequalnans(zscore(singleinf),desired_out)
  errmsgs{end+1} = 'Single_Inf Test: This is not the desired output'
end
clear desired_out;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compares the output the zscore and the zscore_mvpa function using
% a vector with an infiinity value 
% checks if the output with a single inf value is what we expect it to be.
allinf = inf(1,10);
if ~compare_nan(allinf)
  errmsgs{end+1} = 'Comparison Test failed for an all_inf pattern'
end 
desired_out = NaN(1,10);
if ~isequalwithequalnans(zscore(allinf),desired_out)
  errmsgs{end+1} = 'All_Inf Test: This is not the desired output'
end
clear desired_out;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % output the results of this test and the no. of tests it failed
% if isempty(errmsgs)
%   disp('0 tests failed'); 
% else
%  disp(strcat( num2str(size(errmsgs,2)) , '  tests failed.'));   
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [success testno] = compare_versions(x)

success = 1;
testno = [];

if ~isequal( ...
    zscore(x), ...
    zscore_mvpa(x) ...
    )
  
  zscore(x)
  zscore_mvpa(x)
  
  success = 0;
  testno = [testno 1];
end

if ~isequal( ...
    zscore(x), ...
    zscore_mvpa(x,1) ...
    )
  success = 0;
  testno = [testno 2];
end

if ~isequal( ...
    zscore(x')', ...
    zscore_mvpa(x,2) ...
    )
  success = 0;
  testno = [testno 3];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [success testno] = compare_nan(x)

success = 1;
testno = [];

if ~isequalwithequalnans( ...
   zscore(x), ...
   zscore_mvpa(x) ...
    )
  
  success = 0;
  testno = [testno 4];
end

if ~isequalwithequalnans( ...
    zscore(x), ...
    zscore_mvpa(x,1) ...
    )
  success = 0;
  testno = [testno 5];
end

if ~isequalwithequalnans( ...
    zscore(x')', ...
    zscore_mvpa(x,2) ...
    )
  success = 0;
  testno = [testno 6];
end

