function [subj] = ebc_tutorial_adv_load(subjnum, datapath)

% Load an EBC tutorial subject structure from the data.
%
% [SUBJ] = EBC_TUTORIAL_ADV_LOAD(SUBJNUM, DATAPATH)
%
% Loads a tutorial_ebc<SUBJNUM> matrix and then inserts all the
% appropriate data into a new 'subj' structure, which is then returned.
%
% SUBJNUM is the number of the subject to be loaded.
% 
% DATAPATH (optional) is the path to the .mat files; leave blank
% and the path will be assumed to be the current directory.
% 
% License:
%=====================================================================
%
% This is part of the Princeton MVPA toolbox, released under
% the GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% 
% The Princeton MVPA toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the MVPA toolbox.
%
% ======================================================================

% We load the raw data files, optionally passing in a path to the
% data
dataset = '';

if ~exist('datapath')
  dataset = sprintf('tutorial_ebc%d', subjnum);
else
  dataset = sprintf('%stutorial_ebc%d', datapath, subjnum);
end

fprintf('Initializing ''subj'' from dataset ''%s''...', dataset);

load(dataset);

% initialize subj
subj = init_subj('ebc', sprintf('subject_%d', subjnum));

% setup our mask of the whole brain
subj = initset_object(subj, 'mask', 'wholebrain', wholebrain);

% setup the base fMRI pattern
subj = initset_object(subj, 'pattern', 'epi', epi, ...
                      'masked_by', 'wholebrain');

% isolate the first 13 regressors for use
baseregs = baseregs(1:13, :);
condnames = {condnames{1:13}};

% setup our base regressors object
subj = initset_object(subj, 'regressors', 'baseregs', baseregs, ...
                      'condnames', condnames);

% setup our movies selector object
subj = initset_object(subj, 'selector', 'movies', movies);
subj = initset_object(subj, 'selector', ...
		      'movies_noblank', movies_noblank);

% clean up the unneeded raw data we loaded just before:
clear epi baseregs movies movies_noblank condnames wholebrain;

fprintf('completed.\n');
