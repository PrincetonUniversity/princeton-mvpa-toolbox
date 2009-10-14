function [errors] = test_set_mat()

% [success errmsg] = test_set_mat()
%
% This tests the SET_MAT.M function. This is one of the key
% toolbox functions, so if it's broken, even subtly, bad
% things will happen to us all.
%
% These tests are far too sparse. We need to try moving
% things to and from the hard disk, trying to modify
% existing mats, overwriting and removing them, putting
% illegal values in, and play with all the optional
% arguments to check that they work


success = 1;
errmsg = '';

subj = init_subj('testsuite','testsubj');
subj = init_object(subj,'pattern','testpat');

a1 = rand(20);
subj = set_mat(subj,'pattern','testpat',a1);
b1 = get_mat(subj,'pattern','testpat');
success = isequal(a1,b1)
if ~success
  errmsg = 'Getting a matrix just set gives something different';
  return
end

a2 = a1 + 1;
subj = set_mat(subj,'pattern','testpat',a2);
b2 = get_mat(subj,'pattern','testpat');
if ~isequal(a2,b2)
  success = 0;
  errmsg = 'Modifying a matrix doesn''t work right';
  return
end

try
  subj = set_mat(subj,'pattern','testpat','blah');
  success = 0;
  errmsg = 'Didn''t fail when setting a string';
catch
  success = 1;
  errmsg = ''
end

success = iserror('subj = set_mat();')
if ~success
  errmsg = 'no args';
  return
end



try
  success = 0;
  errmsg = 'Didn''t fail when feeding in no arguments';
  subj = set_mat(subj,'pattern','testpat',ones(5));
catch
  success = 1;
  errmsg = '';
end

if ~success
  return
end



function [errors] = test_set_mat()

errors = {};

if ~isequal(blah)
  errors{end+1} = 'problem with the blah test'
end

% I'm checking that you get an error when there are no
% arguments
if ~iserror('subj = set_mat();')
  errors{end+1} = 'no arguments'
end
  
 
