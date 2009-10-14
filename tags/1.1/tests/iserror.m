function [iserr] = iserror(cmd)

% This is part of the MVPA test suite. It evals CMD inside a
% try/catch block. If an error is raised, then returns true. If no
% error is raised, returns false.
%
% This is useful if you're expecting/hoping that a function will
% fail when it's supposed to fail, e.g. if you don't feed in enough
% arguments. If you want to test that:
%
%   if ~iserror('subj = set_mat();')
%     errors{end+1} = 'Was supposed to fail when no arguments were given'
%   end 

iserr = 0;
try
  eval(cmd)
catch
  iserr = 1;
end


