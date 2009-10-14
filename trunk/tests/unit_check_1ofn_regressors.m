function [errs warns] = unit_check_1ofn_regressors() %#ok<STOUT>%ignore that errs and warns arn't used, since no code has been written yet...

% [ERRS WARNS] = UNIT_CHECK_1OFN_REGRESSORS()
%
%Description:
%{
 This function will test the behavior of the check 1ofn_regressors
 function to make sure it meets the requirements set out for it.

 This function is data independent, i.e. it requires no external data to
 run.
%}

errs = {};
warns = {};

%%%%%%%%%%%%%%%%
%Black Box Tests

%Base conditions to test:
%{

ISBOOL - should return a true if all the values are either 1 or 0.
ISREST - should return a true if any of the timepoints lack an active (non-zero) condition
ISOVERACTIVE - should return a true if any of the timepoints have multiple active (non-zero) conditions

%}
%%%%
%Basic Positive Tests
% 8 possible outputs ([0 0 0] -> [1 1 1])

%Test A.0
%[0 0 0]
reg_a0 =   [1 1 1 0 0 0 0 0 0;
            0 0 0 2 2 2 0 0 0;
            0 0 0 0 0 0 3 3 3];
[x y z] = check_1ofn_regressors(reg_a0);
%keyboard;
if ~isequal([x y z],[0 0 0])
    errs{end+1} = 'unit_check_1ofn_regressors(A.0) failed to compare correctly.';
end

%Test A.1
%[1 0 0]
reg_a1=    [1 1 1 0 0 0 0 0 0;
            0 0 0 1 1 1 0 0 0;
            0 0 0 0 0 0 1 1 1];
[x y z] = check_1ofn_regressors(reg_a1);

if ~isequal([x y z],[1 0 0])
    errs{end+1} = 'unit_check_1ofn_regressors(A.1) failed to compare correctly.';
end

%Test A.2
%[0 1 0]
reg_a2=    [1 1 1 0 0 0 0 0 0;
            0 0 0 1 1 0 0 0 0;
            0 0 0 0 0 0 2 2 2];
[x y z] = check_1ofn_regressors(reg_a2);

if ~isequal([x y z],[0 1 0])
    errs{end+1} = 'unit_check_1ofn_regressors(A.2) failed to compare correctly.';
end

%Test A.3
%[1 1 0]
reg_a3=    [1 1 1 0 0 0 0 0 0;
            0 0 0 1 1 0 0 0 0;
            0 0 0 0 0 0 1 1 1];
[x y z] = check_1ofn_regressors(reg_a3);

if ~isequal([x y z],[1 1 0])
    errs{end+1} = 'unit_check_1ofn_regressors(A.3) failed to compare correctly.';
end

%Test A.4
%[0 0 1]
reg_a4=    [1 1 1 0 0 0 0 0 0;
            0 0 0 1 1 1 1 0 0;
            0 0 0 0 0 0 2 2 2];
[x y z] = check_1ofn_regressors(reg_a4);

if ~isequal([x y z],[0 0 1])
    errs{end+1} = 'unit_check_1ofn_regressors(A.4) failed to compare correctly.';
end

%Test A.5
%[1 0 1]
reg_a5=    [1 1 1 0 0 0 0 0 0;
            0 0 0 1 1 1 1 0 0;
            0 0 0 0 0 0 1 1 1];
[x y z] = check_1ofn_regressors(reg_a5);

if ~isequal([x y z],[1 0 1])
    errs{end+1} = 'unit_check_1ofn_regressors(A.5) failed to compare correctly.';
end

%Test A.6
%[0 1 1]
reg_a6=    [1 1 1 0 0 0 0 0 0;
            0 0 0 0 1 1 1 0 0;
            0 0 0 0 0 0 2 2 2];
[x y z] = check_1ofn_regressors(reg_a6);

if ~isequal([x y z],[0 1 1])
    errs{end+1} = 'unit_check_1ofn_regressors(A.6) failed to compare correctly.';
end

%Test A.7
%[1 1 1]
reg_a7=    [1 1 1 0 0 0 0 0 0;
            0 0 0 0 1 1 1 0 0;
            0 0 0 0 0 0 1 1 1];
[x y z] = check_1ofn_regressors(reg_a7);

if ~isequal([x y z],[1 1 1])
    errs{end+1} = 'unit_check_1ofn_regressors(A.7) failed to compare correctly.';
end




%%%%%%%%%%%%%%%%
%White Box Tests

%Test B.0
%Binary test using 2 instead of 1 as the binary value.  Should in fact
%return [0 0 0] since we're only allowing 1's and 0's for ISBOOL to be true.
reg_b0=    [2 2 2 0 0 0 0 0 0;
            0 0 0 2 2 2 0 0 0;
            0 0 0 0 0 0 2 2 2];
[x y z] = check_1ofn_regressors(reg_b0);

if ~isequal([x y z],[0 0 0])
    errs{end+1} = 'unit_check_1ofn_regressors(B.0) failed to compare correctly.';
end
%Test B.1
%Test to make sure negative numbers are handled correctly and not detected
%as an empy column due to negation.
reg_b1=    [1 1 1 0 0 -0.5 0 0 0;
            0 0 0 1 1  0.5 0 0 0;
            0 0 0 0 0    0 1 1 1];
[x y z] = check_1ofn_regressors(reg_b1);

if ~isequal([x y z],[0 0 1])
    errs{end+1} = 'unit_check_1ofn_regressors(B.1) failed to compare correctly.';
end

%Test B.2
%Making sure this is detected as an over active column and not a column
%with only a single value in it.
reg_b2=    [1 1 1 0 0  0 0 0 0;
            0 0 0 1 1  1 0 0 0;
            0 0 0 0 0 -2 1 1 1];
[x y z] = check_1ofn_regressors(reg_b2);

if ~isequal([x y z],[0 0 1])
    errs{end+1} = 'unit_check_1ofn_regressors(B.2) failed to compare correctly.';
end
%Test B.3
%Ensuring this is detected as both a binary representation and as a
%condition with rest. it should have no overactive values.
reg_b3=    [0 0 0 0 0 0 0 0 0;
            0 0 0 0 0 0 0 0 0;
            0 0 0 0 0 0 0 0 0];
[x y z] = check_1ofn_regressors(reg_b3);

if ~isequal([x y z],[1 1 0])
    errs{end+1} = 'unit_check_1ofn_regressors(B.3) failed to compare correctly.';
end
%Test B.4
%Ensuring the basic handling of NaN values is correctly assessed by the
%function. This should not be treated as binary, nor should it be assumed
%to have rest or over active conditions
reg_b4=    [1 1 1 0 0 0 0 0 0;
            0 0 0 NaN 1 1 0 0 0;
            0 0 0 0 0 0 1 1 1];
[x y z] = check_1ofn_regressors(reg_b4);

if ~isequal([x y z],[0 0 0])
    errs{end+1} = 'unit_check_1ofn_regressors(B.4) failed to compare correctly.';
end
%Test B.5
%Ensuring that multiple NaN values are represented as values for the
%purposes of data being used.  This should not be binary or have rest, but
%should show up as over active.
reg_b5=    [1 1 1 NaN 0 0 0 0 0;
            0 0 0 NaN 1 1 0 0 0;
            0 0 0   0 0 0 1 1 1];
[x y z] = check_1ofn_regressors(reg_b5);

if ~isequal([x y z],[0 0 1])
    errs{end+1} = 'unit_check_1ofn_regressors(B.5) failed to compare correctly.';
end
