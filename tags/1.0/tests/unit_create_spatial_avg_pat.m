function [errmsgs warnmsgs] = unit_create_spatial_avg_pat(varargin)

% USAGE :[ERRMSGS WARNMSGS] = TEST_CREATE_SPATIAL_AVG_PAT(...)
% 
% This is a script that tests the spatial averaging functionality.
%
% INPUT ARGUMENTS:
%
% STDOUT (optional, default = true) If true, prints errors and
% warnings to screen as they occur.
%
% OUTPUT ARGUMENTS: 
%
% ERRMSGS = cell array holding the error strings
% describing any tests that failed. If this is empty,
% that's a good thing
%
% WARNMSGS = cell array, like ERRMSGS, of tests that didn't pass
% and didn't fail (e.g. because they weren't run)

defaults.stdout = true;

args = propval(varargin, defaults);

errmsgs = {};
warnmsgs = {};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare test subject

subj = init_subj('test', 'test');
subj = initset_object(subj, 'mask', 'all', ones(5,5,4));
subj = initset_object(subj, 'pattern', 'ones', ones(100, 100), ...
                      'masked_by', 'all');

% mask for testing, 3 coordinates in z axis
onemat_mask= zeros(5,5,4);
onemat_mask([2 2],[2 2],[2 3 4]) = 1;

subj = initset_object(subj, 'mask', 'middle_mask', onemat_mask);

% matrix of all zeros, but one 1 right in the middle of the mask
onemat = zeros(100,100);
onemat(57,:) = ones(1,100);
subj = initset_object(subj, 'pattern', 'middle', onemat,  ...
                      'masked_by', 'all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Negative unit tests

% argument tests:
%   doesn't accept invalid use_neighbor_idx

%   doesn't accept invalid window sizes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Positive unit tests

% simple matrix of all ones: should not change any values
t = 'pattern: all ones, mask: all ones';
try
  [subj neighbor_idx] = create_spatial_avg_pat(subj, 'ones', 'all', ...
                              'new_patname', 'ones_savg_1');

  allones = get_mat(subj, 'pattern', 'ones_savg_1');
  
  if any(allones ~= 1)
    err(sprintf('%s - pattern has been changed\n', t));
  end
    
catch
  err(sprintf('%s - unexpected error: \n**\n%s\n**\n', t, ...
              lasterr));
end

% simple matrix of all zeros except for one voxel of one: its
% neighbors should be 0.5, but all others should be zero
t = 'pattern: all zeros but one, mask: all ones';
try
  [subj neighbor_idx] = create_spatial_avg_pat(subj, 'middle', 'middle_mask', ...
                              'new_patname', 'middle_savg_1');

  middle = get_mat(subj, 'pattern', 'middle_savg_1');

  if numel(neighbor_idx) ~= 3 | any(neighbor_idx{1} ~= [1;2]) | ...
        any(neighbor_idx{2} ~= [1;2;3]) | any(neighbor_idx{3} ~= [2;3])
    
    err(sprintf('%s - improper neighbor_idx\n', t));
  end
        
  if middle(:, 1) ~= [1/2;1/3;1/2]
    err(sprintf('%s - invalid middle values\n', t));
  end
      
catch
  err(sprintf('%s - unexpected error: \n**\n%s\n**\n', t, ...
              lasterr));
end


% simple matrix of all ones, with empty mask: all voxels --> 0

% more advanced tests???

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Standard Testing Utility Functions

fprintf('%s: All tests completed.\n\t %d failures, %d warnings.\n', ...
        mfilename, numel(errmsgs), numel(warnmsgs));

function out = approx(a, b, tolerance)

if abs(a - b) < tolerance
  out = true;
else
  out = false;
end

end

function err(testmsg) 

e = sprintf('Test failed: %s\n', testmsg);
errmsgs{end+1} = e;

if (args.stdout)
  fprintf(e);
end

end

function warn(warnmsg)

w = sprintf('Warning: %s\n', warnmsg);
warnmsgs{end+1} = w;

if (args.stdout)
  fprintf(w);
end

end

end

