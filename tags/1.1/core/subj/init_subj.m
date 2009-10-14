function [subj] = init_subj(exp_name,id,varargin)

% Returns an empty initialized SUBJ structure
%
% [SUBJ] = INIT_SUBJ(EXP_NAME,ID,...)
%
% The empty SUBJ structure contains no patterns, regressors, selectors
% masks. Adds some rudimentary header info, including the following
% string arguments
%
% EXP_NAME: The name of the experiment
%
% ID: a unique identifier for the subj, e.g. id/name/initials
%
% SUBDIR: (optional, default is exp_name id datetime) The
% subdirectory for storing auxiliary files. There's really
% no reason to change this.
%
% USERNAME (optional, default = ''): The user's name
%
% e.g. subj = init_subj('my_experiment','GJD')
%      subj = init_subj('my_experiment','GJD','mydatadir','greg');

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


version = 3;
created = datetime(true);

defaults.subdir = sprintf('%s_%s_%s',exp_name,id,created);
defaults.username = '';
args = propval(varargin,defaults);

% Initializes a new subject structure

subj.patterns   = {};
subj.regressors = {};
subj.selectors  = {};
subj.masks      = {};
subj.header     = [];

header.experiment = exp_name;
header.version    = version;
header.history    = {sprintf('Initialized on %s',created)};
header.created    = created;
header.subdir     = args.subdir;
header.username   = args.username;
header.id         = id;
subj = set_objfield(subj,'subj','','header',header);

subj.p  = 'Unspecified';
subj.s  = 'Unspecified';
subj.m  = 'Unspecified';
subj.r  = 'Unspecified';

