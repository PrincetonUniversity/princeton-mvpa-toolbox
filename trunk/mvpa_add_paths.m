function [] = mvpa_add_paths()

% Adds the paths necessary to use the MVPA Toolbox. Assumes
% that you've already got this script in your path, and so
% it uses the location of this script to determine the root
% directory of the rest of the MVPA scripts. That way, it
% doesn't need an argument.
%
% Usage: MVPA_ADD_PATHS


% find the root path
rootdir = fileparts(which('mvpa_add_paths'));

% fprintf('Adding MVPA paths (root: ''%s'')...\n', rootdir);

% Add MVPA core paths.
myaddpath('core');
myaddpath('core/ebc');
myaddpath('core/io');
myaddpath('core/learn');
myaddpath('core/preproc');
myaddpath('core/subj');
myaddpath('core/util');
myaddpath('core/vis');
myaddpath('core/template');

% Uncomment the following line to restore deprecated functions:
myaddpath('core/deprecated');

% Add paths for packages bundled with the toolbox.
% myaddpath('adaboost_mkc');
myaddpath('afni_matlab');
myaddpath('boosting');
myaddpath('bv2mat');
myaddpath('montage_kas');
myaddpath('netlab');

% nested wrapper for adding relative paths
function myaddpath(p)
  addpath([rootdir '/' p]);
end

end
